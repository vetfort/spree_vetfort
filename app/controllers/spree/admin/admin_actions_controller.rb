module Spree
  module Admin
    class AdminActionsController < Spree::Admin::BaseController
      def index
        @events = Ahoy::Event.order(time: :desc)
                             .page(params[:page])
                             .per(20)
      end
    end
  end
end
