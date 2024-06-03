# Spree::Admin::SpreeVetfort::VetfortNavigationHelper

module Spree
  module Admin
    module SpreeVetfort
      module VetfortNavigationHelper
        def vetfort_offline_order_tabs
          Rails.application.config.spree_backend.tabs[:vetfort_order_tabs]
        end

        def vetfort_offline_order_actions
          Rails.application.config.spree_backend.actions[:vetfort_order]
        end
      end
    end
  end
end
