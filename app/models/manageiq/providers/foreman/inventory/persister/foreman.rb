class ManageIQ::Providers::Foreman::Inventory::Persister::Foreman < ManageIQ::Providers::Foreman::Inventory::Persister
  def initialize_inventory_collections
    add_configuration_collection(:configuration_profiles) { |b| b.add_properties(:attributes_blacklist => %i[configuration_tags_hash]) }
    add_configuration_collection(:configured_systems) { |b| b.add_properties(:attributes_blacklist => %i[configuration_tags_hash]) }
    add_provisioning_collection(:customization_script_media)
    add_provisioning_collection(:customization_script_ptables)
    add_provisioning_collection(:operating_system_flavors)
    add_provisioning_collection(:configuration_locations)
    add_provisioning_collection(:configuration_organizations)
    add_provisioning_collection(:configuration_architectures)
    add_provisioning_collection(:configuration_compute_profiles)
    add_provisioning_collection(:configuration_domains)
    add_provisioning_collection(:configuration_environments)
    add_provisioning_collection(:configuration_realms)
  end

  private

  def add_configuration_collection(collection_name, extra_properties = {}, settings = {}, &block)
    add_collection_for_manager("configuration", collection_name, extra_properties, settings, &block)
  end

  def add_provisioning_collection(collection_name, extra_properties = {}, settings = {}, &block)
    add_collection_for_manager("provisioning", collection_name, extra_properties, settings, &block)
  end

  def configuration_manager
    manager.kind_of?(ManageIQ::Providers::ConfigurationManager) ? manager : manager.provider.configuration_manager
  end

  def provisioning_manager
    manager.kind_of?(ManageIQ::Providers::ProvisioningManager) ? manager : manager.provider.provisioning_manager
  end
end
