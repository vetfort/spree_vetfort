module Spree
  module Admin
    UsersController.class_eval do
      after_action :track_user_changes, only: [:create, :update, :destroy]

      private

      def track_user_changes
        case action_name
        when "create"
          ahoy.track "Created user", track_payload
        when "update"
          ahoy.track "Updated user", track_payload
        when "destroy"
          ahoy.track "Deleted user", track_payload
        end
      end

      def track_payload
        payload = {
          user_id:    @user.id,
          user_name:  @user.email,
          admin_id:   try_spree_current_user.id,
          admin_name: try_spree_current_user.email,
        }

        if action_name == "update"
          payload[:diff] = @user.saved_changes
        end

        payload
      end
    end
  end
end
