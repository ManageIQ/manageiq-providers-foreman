class ManageIQ::Providers::Foreman::ProvisioningManager < ManageIQ::Providers::ProvisioningManager
  require_nested :Refresher
  require_nested :RefreshParser

  delegate :authentication_check,
           :authentication_status,
           :authentication_status_ok?,
           :connect,
           :verify_credentials,
           :with_provider_connection,
           :to => :provider

  class << self
    delegate :params_for_create,
             :verify_credentials,
             :to => ManageIQ::Providers::Foreman::Provider
  end

  has_many :configuration_locations,    :foreign_key => :provisioning_manager_id
  has_many :configuration_organizations, :foreign_key => :provisioning_manager_id

  def self.ems_type
    @ems_type ||= "foreman_provisioning".freeze
  end

  def self.description
    @description ||= "Foreman Provisioning".freeze
  end

  def self.supported_for_create?
    false
  end
end
