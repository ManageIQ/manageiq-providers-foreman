class ManageIQ::Providers::Foreman::Inventory::Parser::Foreman < ManageIQ::Providers::Foreman::Inventory::Parser
  def parse
    customization_scripts

    persister_profiles = configuration_profiles
    configured_systems(persister_profiles)
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
    configuration_profiles = collector.hostgroups.map do |hostgroup|
      parent_ref = hostgroup["ancestry"]&.split("/")&.last&.presence
      parent     = persister.configuration_profiles.lazy_find(parent_ref) if parent_ref

      persister.configuration_profiles.build(
        :manager_ref => hostgroup["id"].to_s,
        :parent      => parent,
        :name        => hostgroup["name"],
        :description => hostgroup["title"],
        :direct_operating_system_flavor     => persister.operating_system_flavors.lazy_find(hostgroup["operatingsystem_id"]),
        :direct_customization_script_medium => persister.customization_script_media.lazy_find(hostgroup["medium_id"]),
        :direct_customization_script_ptable => persister.customization_script_ptables.lazy_find(hostgroup["ptable_id"])
      )
    end

    configuration_profiles.each do |profile|
      ancestor_values = family_tree(configuration_profiles, profile).map do |hash|
        {
          :operating_system_flavor     => hash.direct_operating_system_flavor,
          :customization_script_medium => hash.direct_customization_script_medium,
          :customization_script_ptable => hash.direct_customization_script_ptable
        }
      end

      rollup(profile, ancestor_values)
    end

    configuration_profiles
  end

  def configured_systems(persister_profiles)
    persister_profiles_by_ref = persister_profiles.index_by do |profile|
      profile.data[:manager_ref]
    end

    configured_systems = collector.hosts.map do |host|
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
        :configuration_profile              => persister_profiles_by_ref[host["hostgroup_id"].to_s]
      )
    end

    configured_systems.each do |system|
      parent = system.configuration_profile || {}

      system.data.merge!(
        :operating_system_flavor     => system.direct_operating_system_flavor.presence || parent.operating_system_flavor.presence,
        :customization_script_medium => system.direct_customization_script_medium.presence || parent.customization_script_medium.presence,
        :customization_script_ptable => system.direct_customization_script_ptable.presence || parent.customization_script_ptable_id.presence,
        #:configuration_tag_ids          => tag_id_lookup(indexes, rollup({}, configuration_tag_hashes)),
      )
    end

    configured_systems
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

  # given an array of hashes, squash the values together, last value taking precidence
  def rollup(target, records)
    records.each do |record|
      target.data.merge!(record.select { |_n, v| !v.nil? && v != "" })
    end
    target
  end

  # walk collection returning [ancestor, grand parent, parent, child_record]
  def family_tree(collection, record)
    ret = []
    loop do
      ret << record
      parent_ref = record.parent&.stringified_reference
      return ret.reverse unless parent_ref
      record = collection.detect { |r| r[:manager_ref] == parent_ref }
    end
  end
end
