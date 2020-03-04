class ManageIQ::Providers::Foreman::Inventory::Parser < ManageIQ::Providers::Inventory::Parser
  require_nested :ConfigurationManager
  require_nested :ProvisioningManager
end
