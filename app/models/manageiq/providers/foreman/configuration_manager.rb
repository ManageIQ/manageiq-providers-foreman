class ManageIQ::Providers::Foreman::ConfigurationManager < ManageIQ::Providers::ConfigurationManager
  require_nested :ConfigurationProfile
  require_nested :ConfiguredSystem
  require_nested :ProvisionTask
  require_nested :ProvisionWorkflow
  require_nested :Refresher
  require_nested :RefreshWorker

  include ProcessTasksMixin
  delegate :authentication_check,
           :authentication_status,
           :authentication_status_ok?,
           :authentications,
           :connect,
           :endpoints,
           :url,
           :url=,
           :verify_credentials,
           :with_provider_connection,
           :to => :provider

  belongs_to :provider, :autosave => true

  class << self
    delegate :params_for_create,
             :verify_credentials,
             :to => ManageIQ::Providers::Foreman::Provider
  end

  def self.ems_type
    @ems_type ||= "foreman_configuration".freeze
  end

  def self.description
    @description ||= "Foreman Configuration".freeze
  end

  def provider
    super || ensure_provider
  end

  def image_name
    "foreman_configuration"
  end

  def self.display_name(number = 1)
    n_('Configuration Manager (Foreman)', 'Configuration Managers (Foreman)', number)
  end

  def ensure_provider
    build_provider

    provider.configuration_manager = self
    provider.name = name
    provider.zone = zone

    provider
  end
end
