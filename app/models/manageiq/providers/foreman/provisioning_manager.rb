class ManageIQ::Providers::Foreman::ProvisioningManager < ManageIQ::Providers::ProvisioningManager
  require_nested :Refresher

  delegate :authentication_check,
           :authentication_status,
           :authentication_status_ok?,
           :authentications,
           :authentications=,
           :connect,
           :endpoints,
           :endpoints=,
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

  def provider
    super || ensure_provider
  end

  def name
    "#{provider.name} Provisioning Manager"
  end

  delegate :name=, :zone, :zone=, :zone_id, :zone_id=, :to => :provider

  private

  def ensure_provider
    build_provider.tap { |p| p.provisioning_manager = self }
  end
end
