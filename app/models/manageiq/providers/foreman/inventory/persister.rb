class ManageIQ::Providers::Foreman::Inventory::Persister < ManageIQ::Providers::Inventory::Persister
  require_nested :Foreman
  require_nested :ConfigurationManager
  require_nested :ProvisioningManager
end
