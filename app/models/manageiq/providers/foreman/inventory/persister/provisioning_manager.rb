class ManageIQ::Providers::Foreman::Inventory::Persister::ProvisioningManager < ManageIQ::Providers::Foreman::Inventory::Persister
  def initialize_inventory_collections
    add_collection(provisioning, :customization_scripts)
    add_collection(provisioning, :operating_system_flavors)
    add_collection(provisioning, :configuration_locations)
    add_collection(provisioning, :configuration_organizations)
    add_collection(provisioning, :configuration_tags)
  end
end
