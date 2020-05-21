class ManageIQ::Providers::Foreman::Provider < ::Provider
  has_one :configuration_manager,
          :foreign_key => "provider_id",
          :class_name  => "ManageIQ::Providers::Foreman::ConfigurationManager",
          :dependent   => :destroy,
          :autosave    => true
  has_one :provisioning_manager,
          :foreign_key => "provider_id",
          :class_name  => "ManageIQ::Providers::Foreman::ProvisioningManager",
          :dependent   => :destroy,
          :autosave    => true

  has_many :endpoints, :as => :resource, :dependent => :destroy, :autosave => true

  delegate :url,
           :url=,
           :to => :default_endpoint

  virtual_column :url, :type => :string, :uses => :endpoints

  delegate :api_cached?, :ensure_api_cached, :to => :connect

  before_validation :ensure_managers

  validates :name, :presence => true, :uniqueness => true
  validates :url,  :presence => true

  def self.description
    @description ||= "Foreman".freeze
  end

  def self.params_for_create
    @params_for_create ||= {
      :fields => [
        {
          :component => 'sub-form',
          :name      => 'endpoints-subform',
          :title     => _("Endpoint"),
          :fields    => [
            {
              :component              => 'validate-provider-credentials',
              :name                   => 'authentications.default.valid',
              :skipSubmit             => true,
              :validationDependencies => %w[type zone_id],
              :fields                 => [
                {
                  :component  => "text-field",
                  :name       => "endpoints.default.url",
                  :label      => _("URL"),
                  :isRequired => true,
                  :validate   => [{:type => "required-validator"}]
                },
                {
                  :component => "checkbox",
                  :name      => "endpoints.default.verify_ssl",
                  :label     => _("Verify Peer Certificate")
                },
                {
                  :component  => "text-field",
                  :name       => "authentications.default.userid",
                  :label      => _("Username"),
                  :helperText => _("Should have privileged access, such as root or administrator."),
                  :isRequired => true,
                  :validate   => [{:type => "required-validator"}]
                },
                {
                  :component  => "password-field",
                  :name       => "authentications.default.password",
                  :label      => _("Password"),
                  :type       => "password",
                  :isRequired => true,
                  :validate   => [{:type => "required-validator"}]
                },
              ],
            },
          ],
        },
      ]
    }.freeze
  end

  # Verify Credentials
  # args: {
  #  "endpoints" => {
  #    "default" => {
  #       "url" => nil,
  #       "verify_ssl" => nil
  #    },
  #  },
  #  "authentications" => {
  #     "default" => {
  #       "userid" => nil,
  #       "password" => nil,
  #     }
  #   }
  # }
  def self.verify_credentials(args)
    default_authentication = args.dig("authentications", "default")
    base_url = args.dig("endpoints", "default", "url")
    verify_ssl = args.dig("endpoints", "default", "verify_ssl")
    userid, password = default_authentication&.values_at("userid", "password")
    verify_ssl = verify_ssl ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
    !!raw_connect(base_url, userid, password, verify_ssl).verify?
  end

  def self.raw_connect(base_url, username, password, verify_ssl)
    require 'foreman_api_client'
    ForemanApiClient.logger ||= $log
    ForemanApiClient::Connection.new(
      :base_url   => base_url,
      :username   => username,
      :password   => MiqPassword.try_decrypt(password),
      :timeout    => 100,
      :verify_ssl => verify_ssl
    )
  end

  def connect(options = {})
    auth_type = options[:auth_type]
    raise "no credentials defined" if self.missing_credentials?(auth_type)

    verify_ssl = options[:verify_ssl] || self.verify_ssl
    base_url   = options[:url] || url
    username   = options[:username] || authentication_userid(auth_type)
    password   = options[:password] || authentication_password(auth_type)

    self.class.raw_connect(base_url, username, password, verify_ssl)
  end

  def verify_credentials(auth_type = nil, options = {})
    uri = URI.parse(url) unless url.blank?
    unless uri.kind_of?(URI::HTTPS)
      raise "URL has to be HTTPS"
    end
    with_provider_connection(options.merge(:auth_type => auth_type), &:verify?)
  rescue SocketError,
         Errno::ECONNREFUSED,
         RestClient::ResourceNotFound,
         RestClient::InternalServerError => err
    raise MiqException::MiqUnreachableError, err.message, err.backtrace
  rescue RestClient::Unauthorized => err
    raise MiqException::MiqInvalidCredentialsError, err.message, err.backtrace
  end

  private

  def ensure_managers
    build_provisioning_manager unless provisioning_manager
    provisioning_manager.name    = "#{name} Provisioning Manager"

    build_configuration_manager unless configuration_manager
    configuration_manager.name    = "#{name} Configuration Manager"

    if zone_id_changed?
      provisioning_manager.enabled = Zone.maintenance_zone&.id != zone_id
      provisioning_manager.zone_id = zone_id
      configuration_manager.enabled = Zone.maintenance_zone&.id != zone_id
      configuration_manager.zone_id = zone_id
    end
  end

  def self.refresh_ems(provider_ids)
    EmsRefresh.queue_refresh(Array.wrap(provider_ids).collect { |id| [base_class, id] })
  end
end
