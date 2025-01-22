module Spree
  module Admin
    OrdersController.class_eval do
      after_action :track_order_changes, only: [:update, :destroy]

      private

      def track_order_changes
        case action_name
        when "update"
          ahoy.track "Updated order", track_payload
        when "destroy"
          ahoy.track "Deleted order", track_payload
        end
      end

      def track_payload
        payload = {
          order_id:     @order.id,
          order_number: @order.number,
          admin_id:     try_spree_current_user.id,
          admin_name:   try_spree_current_user.email,
        }

        if action_name == "update"
          payload[:diff] = @order.saved_changes
        end

        payload
      end
    end
  end
end
