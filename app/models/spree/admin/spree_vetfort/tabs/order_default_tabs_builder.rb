# Spree::Admin::SpreeVetfort::Tabs::OrderDefaultTabsBuilder

module Spree
  module Admin
    module SpreeVetfort
      module Tabs
        class OrderDefaultTabsBuilder
          include Spree::Core::Engine.routes.url_helpers

          def build
            root = Spree::Admin::Tabs::Root.new
            add_cart_tab(root)
            # add_adjustments_tab(root)

            root
          end

          private

          def add_cart_tab(root)
            tab =
              Spree::Admin::Tabs::TabBuilder.new('cart', ->(resource) { cart_admin_spree_vetfort_offline_path(resource) }).
              with_icon_key('cart-check.svg').
              with_active_check.
              with_availability_check(
                # An abstract module should not be aware of resource's internal structure.
                # If these checks are elaborate, it's better to have this complexity declared explicitly here.
                lambda do |ability, resource|
                  ability.can?(:update, resource) && (resource.shipments.empty? || resource.shipments.shipped.empty?)
                end
              ).
              with_data_hook('admin_order_tabs_cart_details').
              build

            root.add(tab)
          end

          def add_adjustments_tab(root)
            tab =
              Spree::Admin::Tabs::TabBuilder.new('adjustments', ->(resource) { admin_order_adjustments_path(resource) }).
              with_icon_key('adjust.svg').
              with_active_check.
              with_index_ability_check(::Spree::Adjustment).
              with_data_hook('admin_order_tabs_adjustments').
              build

            root.add(tab)
          end
        end
      end
    end
  end
end
