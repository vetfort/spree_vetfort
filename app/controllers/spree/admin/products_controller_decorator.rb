module Spree
  module Admin
    module ProductsControllerDecorator
      def self.prepended(base)
        base.class_eval do
          after_action :track_product_changes, only: %i[create update destroy]

          private

          def track_product_changes
            case action_name
            when 'create'
              ahoy.track 'Created product', track_payload
            when 'update'
              ahoy.track 'Updated product', track_payload
            when 'destroy'
              ahoy.track 'Deleted product', track_payload
            end
          end

          def track_payload
            payload = {
              product_id: @product.id,
              product_name: @product.name,
              admin_id: try_spree_current_user.id,
              admin_name: try_spree_current_user.email
            }

            payload[:diff] = @product.saved_changes if action_name == 'update'

            payload
          end
        end
      end
    end
  end
end

Spree::Admin::ProductsController.prepend(Spree::Admin::ProductsControllerDecorator)
