class ManageIQ::Providers::Foreman::Inventory::Persister::Foreman < ManageIQ::Providers::Foreman::Inventory::Persister
  def initialize_inventory_collections
    add_configuration_collection(:configuration_profiles) { |b| b.add_properties(:attributes_blacklist => %i[configuration_tags_hash]) }
    add_configuration_collection(:configured_systems) { |b| b.add_properties(:attributes_blacklist => %i[configuration_tags_hash]) }
    add_provisioning_collection(:customization_script_media, :default_value_key => :manager_id)
    add_provisioning_collection(:customization_script_ptables, :default_value_key => :manager_id)
    add_provisioning_collection(:operating_system_flavors)
    add_provisioning_collection(:configuration_locations)
    add_provisioning_collection(:configuration_organizations)
    add_provisioning_collection(:configuration_architectures, :default_value_key => :manager_id)
    add_provisioning_collection(:configuration_compute_profiles, :default_value_key => :manager_id)
    add_provisioning_collection(:configuration_domains, :default_value_key => :manager_id)
    add_provisioning_collection(:configuration_environments, :default_value_key => :manager_id)
    add_provisioning_collection(:configuration_realms, :default_value_key => :manager_id)
  end

  private

  def add_configuration_collection(collection)
    add_collection(configuration, collection) do |builder|
      builder.add_properties(:parent => manager.provider.configuration_manager)
      builder.add_default_values(
        :manager_id => ->(persister) { persister.manager.provider.configuration_manager.id }
      )
      yield builder if block_given?
    end
  end

  def add_provisioning_collection(collection, default_value_key: :provisioning_manager_id)
    add_collection(provisioning, collection) do |builder|
      builder.add_properties(:parent => manager.provider.provisioning_manager)
      builder.add_default_values(
        default_value_key => ->(persister) { persister.manager.provider.provisioning_manager.id }
      )
    end
  end
end
