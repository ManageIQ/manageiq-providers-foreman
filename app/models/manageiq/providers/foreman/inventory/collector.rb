class ManageIQ::Providers::Foreman::Inventory::Collector < ManageIQ::Providers::Inventory::Collector
  require_nested :ConfigurationManager
  require_nested :ProvisioningManager
end
