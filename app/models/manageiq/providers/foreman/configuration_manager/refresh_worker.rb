class ManageIQ::Providers::Foreman::ConfigurationManager::RefreshWorker < MiqEmsRefreshWorker
  require_nested :Runner

  def self.settings_name
    :ems_refresh_worker_foreman_configuration
  end

  # overriding queue_name_for_ems so PerEmsWorkerMixin picks up *all* of the
  # Foreman-managers from here.
  # This way, the refresher for Foreman's ConfigurationManager will refresh *all*
  # of the inventory across all managers.
  class << self
    def queue_name_for_ems(ems)
      return ems unless ems.kind_of?(ExtManagementSystem)

      ems.provider.managers.collect(&:queue_name).sort
    end
  end
end
