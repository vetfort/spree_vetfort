module SpreeVetfort
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_vetfort'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    config.after_initialize do
      Rails.application.config.spree_backend.tabs[:vetfort_order_tabs] = Spree::Admin::SpreeVetfort::Tabs::OrderDefaultTabsBuilder.new.build
      Rails.application.config.spree_backend.actions[:vetfort_order] = Spree::Admin::SpreeVetfort::Actions::OrderDefaultActionsBuilder.new.build
    end

    initializer 'spree_vetfort.environment', before: :load_config_initializers do |_app|
      SpreeVetfort::Config = SpreeVetfort::Configuration.new
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
