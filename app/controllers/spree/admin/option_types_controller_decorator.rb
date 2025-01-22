module Spree
  module Admin
    OptionTypesController.class_eval do
      after_action :track_option_type_changes, only: [:create, :update, :destroy]

      private

      def track_option_type_changes
        case action_name
        when "create"
          ahoy.track "Created option type", track_payload
        when "update"
          ahoy.track "Updated option type", track_payload
        when "destroy"
          ahoy.track "Deleted option type", track_payload
        end
      end

      def track_payload
        payload = {
          option_type_id:   @option_type.id,
          option_type_name: @option_type.name,
          admin_id:         try_spree_current_user.id,
          admin_name:       try_spree_current_user.email,
        }

        if action_name == "update"
          payload[:diff] = @option_type.saved_changes
        end

        payload
      end
    end
  end
end
