module ManageIQ
  module Providers
    module Foreman
      class Engine < ::Rails::Engine
        isolate_namespace ManageIQ::Providers::Foreman
      end
    end
  end
end
