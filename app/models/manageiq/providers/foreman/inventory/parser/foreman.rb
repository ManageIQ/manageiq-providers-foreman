class ManageIQ::Providers::Foreman::Inventory::Parser::Foreman < ManageIQ::Providers::Foreman::Inventory::Parser
  def parse
    customization_scripts
    configuration_profiles
    configured_systems
    operating_system_flavors
    configuration_locations
    configuration_organizations
    configuration_architectures
    configuration_compute_profiles
    configuration_domains
    configuration_environments
    configuration_realms
  end

  private

  def customization_scripts
    collector.media.each do |medium|
      persister.customization_script_media.build(
        :manager_ref => medium["id"].to_s,
        :name        => medium["name"]
      )
    end

    collector.ptables.each do |ptable|
      persister.customization_script_ptables.build(
        :manager_ref => ptable["id"].to_s,
        :name        => ptable["name"]
      )
    end
  end

  def configuration_profiles
    collector.hostgroups.each do |hostgroup|
      persister.configuration_profiles.build(
        :manager_ref => hostgroup["id"].to_s,
        :parent_ref  => (hostgroup["ancestry"] || "").split("/").last.presence,
        :name        => hostgroup["name"],
        :description => hostgroup["title"],
        :direct_operating_system_flavor     => persister.operating_system_flavors.lazy_find(hostgroup["operatingsystem_id"]),
        :direct_customization_script_medium => persister.customization_script_media.lazy_find(hostgroup["medium_id"]),
        :direct_customization_script_ptable => persister.customization_script_ptables.lazy_find(hostgroup["ptable_id"])
      )
    end
  end

  def configured_systems
    collector.hosts.each do |host|
      persister.configured_systems.build(
        :manager_ref                        => host["id"].to_s,
        :hostname                           => host["name"],
        :last_checkin                       => host["last_compile"],
        :build_state                        => host["build"] ? "pending" : nil,
        :ipaddress                          => host["ip"],
        :mac_address                        => host["mac"],
        :ipmi_present                       => host["sp_ip"].present?,
        :direct_operating_system_flavor     => persister.operating_system_flavors.lazy_find(host["operatingsystem_id"]),
        :direct_customization_script_medium => persister.customization_script_media.lazy_find(host["medium_id"]),
        :direct_customization_script_ptable => persister.customization_script_ptables.lazy_find(host["ptable_id"]),
      )
    end
  end

  def operating_system_flavors
    collector.operating_systems.each do |os|
      persister.operating_system_flavors.build(
        :manager_ref => os["id"].to_s,
        :name        => os["fullname"],
        :description => os["description"]
      )
    end
  end

  def configuration_locations
    collector.locations.each do |location|
      persister.configuration_locations.build(
        :manager_ref => location["id"].to_s,
        :name        => location["name"],
      )
    end
  end

  def configuration_organizations
    collector.organizations.each do |org|
      persister.configuration_organizations.build(
        :manager_ref => org["id"].to_s,
        :name        => org["name"],
      )
    end
  end

  def configuration_architectures
    collector.architectures.each do |arch|
      persister.configuration_architectures.build(
        :manager_ref => arch["id"].to_s,
        :name        => arch["name"],
      )
    end
  end

  def configuration_compute_profiles
    collector.compute_profiles.each do |profile|
      persister.configuration_compute_profiles.build(
        :manager_ref => profile["id"].to_s,
        :name        => profile["name"],
      )
    end
  end

  def configuration_domains
    collector.domains.each do |domain|
      persister.configuration_domains.build(
        :manager_ref => domain["id"].to_s,
        :name        => domain["name"],
      )
    end
  end

  def configuration_environments
    collector.environments.each do |env|
      persister.configuration_environments.build(
        :manager_ref => env["id"].to_s,
        :name        => env["name"],
      )
    end
  end

  def configuration_realms
    collector.realms.each do |realm|
      persister.configuration_realms.build(
        :manager_ref => realm["id"].to_s,
        :name        => realm["name"],
      )
    end
  end
end
