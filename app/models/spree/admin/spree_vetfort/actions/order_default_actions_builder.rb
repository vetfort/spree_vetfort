module Spree
  module Admin
    module SpreeVetfort
      module Actions
        class OrderDefaultActionsBuilder
          include Spree::Core::Engine.routes.url_helpers

          def build
            root = Spree::Admin::Actions::Root.new
            add_approve_action(root)
            root
          end

          private

          def add_approve_action(root)
            action =
              Spree::Admin::Actions::ActionBuilder.new('approve', ->(resource) { approve_admin_spree_vetfort_offline_path(resource) }).
              with_icon_key('approve.svg').
              with_label_translation_key('admin.spree_vetfort.order.events.approve').
              with_method(:put).
              # with_data_attributes({ confirm: Spree.t(:order_sure_want_to, event: :approve) }).
              with_state_change_check('approve').
              with_fire_ability_check.
              build

            root.add(action)
          end
        end
      end
    end
  end
end
