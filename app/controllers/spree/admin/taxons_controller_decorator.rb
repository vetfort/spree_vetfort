module Spree
  module Admin
    module TaxonsControllerDecorator
      def self.prepended(base)
        base.class_eval do
          after_action :track_taxon_changes, only: %i[create update destroy]

          private

          def track_taxon_changes
            case action_name
            when 'create'
              ahoy.track 'Created taxon', track_payload
            when 'update'
              ahoy.track 'Updated taxon', track_payload
            when 'destroy'
              ahoy.track 'Deleted taxon', track_payload
            end
          end

          def track_payload
            payload = {
              taxon_id: @taxon.id,
              taxon_name: @taxon.name,
              admin_id: try_spree_current_user.id,
              admin_name: try_spree_current_user.email
            }

            payload[:diff] = @taxon.saved_changes if action_name == 'update'

            payload
          end
        end
      end
    end
  end
end

Spree::Admin::TaxonsController.prepend(Spree::Admin::TaxonsControllerDecorator)
