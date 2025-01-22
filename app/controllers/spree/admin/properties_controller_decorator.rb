module Spree
  module Admin
    module PropertiesControllerDecorator
      def self.prepended(base)
        base.class_eval do
          after_action :track_property_changes, only: %i[create update destroy]

          private

          def track_property_changes
            case action_name
            when 'create'
              ahoy.track 'Created property', track_payload
            when 'update'
              ahoy.track 'Updated property', track_payload
            when 'destroy'
              ahoy.track 'Deleted property', track_payload
            end
          end

          def track_payload
            payload = {
              property_id: @property.id,
              property_name: @property.name,
              admin_id: try_spree_current_user.id,
              admin_name: try_spree_current_user.email
            }

            payload[:diff] = @property.saved_changes if action_name == 'update'

            payload
          end
        end
      end
    end
  end
end

Spree::Admin::PropertiesController.prepend(Spree::Admin::PropertiesControllerDecorator)
