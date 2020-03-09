class ManageIQ::Providers::Foreman::Inventory::Parser < ManageIQ::Providers::Inventory::Parser
  require_nested :Foreman
  require_nested :ConfigurationManager
  require_nested :ProvisioningManager
end
