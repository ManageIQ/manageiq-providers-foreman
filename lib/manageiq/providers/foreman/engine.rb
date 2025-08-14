module ManageIQ
  module Providers
    module Foreman
      class Engine < ::Rails::Engine
        isolate_namespace ManageIQ::Providers::Foreman

        config.autoload_paths << root.join('lib')

        def self.vmdb_plugin?
          true
        end

        def self.plugin_name
          _('Foreman Provider')
        end
      end
    end
  end
end
