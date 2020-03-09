class ManageIQ::Providers::Foreman::Inventory::Collector::Foreman < ManageIQ::Providers::Foreman::Inventory::Collector
  def hostgroups
    inventory[:hostgroups]
  end

  def hosts
    inventory[:hosts]
  end

  def operating_systems
    inventory[:operating_systems]
  end

  def media
    inventory[:media]
  end

  def ptables
    inventory[:ptables]
  end

  def locations
    inventory[:locations] || default_taxonamy_refs
  end

  def organizations
    inventory[:organizations] || default_taxonamy_refs
  end

  def architectures
    inventory[:architectures]
  end

  def compute_profiles
    inventory[:compute_profiles]
  end

  def domains
    inventory[:domains]
  end

  def environments
    inventory[:environments]
  end

  def realms
    inventory[:realms]
  end

  private

  def inventory
    @inventory ||= manager.with_provider_connection { |connection| fetch_inventory(connection) }
  end

  def fetch_inventory(connection)
    hosts = connection.all(:hosts)
    hostgroups = connection.all(:hostgroups)

    # if locations or organizations are enabled (detected by presence in host records)
    #    but it is not present in hostgroups
    #   fetch details for a hostgroups (to get location and organization information)
    host = hosts.first
    hostgroup = hostgroups.first
    if host && hostgroup && (
       (host.key?("location_id") && !hostgroup.key?("locations")) ||
       (host.key?("organization_id") && !hostgroup.key?("organizations")))
      hostgroups = connection.load_details(hostgroups, :hostgroups)
    end
    {
      :hosts             => hosts,
      :hostgroups        => hostgroups,
      :operating_systems => connection.all_with_details(:operatingsystems),
      :media             => connection.all(:media),
      :ptables           => connection.all(:ptables),
      :locations         => connection.all(:locations),
      :organizations     => connection.all(:organizations),
      :architectures     => connection.all(:architectures),
      :compute_profiles  => connection.all(:compute_profiles),
      :domains           => connection.all(:domains),
      :environments      => connection.all(:environments),
      :realms            => connection.all(:realms),
    }
  end

  # default taxonomy reference (locations and organizations)
  def default_taxonamy_refs
    [{"id" => 0, "name" => "Default", "title" => "Default"}]
  end
end
