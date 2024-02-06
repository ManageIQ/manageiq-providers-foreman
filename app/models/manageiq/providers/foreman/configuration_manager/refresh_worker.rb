class ManageIQ::Providers::Foreman::ConfigurationManager::RefreshWorker < MiqEmsRefreshWorker
  def self.settings_name
    :ems_refresh_worker_foreman_configuration
  end
end
