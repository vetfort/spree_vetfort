module Spree::Admin::SpreeVetfort
  class OfflineController < Spree::Admin::BaseController
    include Spree::Backend::Callbacks
    include Spree::Admin::OrderConcern
    include Spree::Admin::SpreeVetfort::VetfortNavigationHelper

    helper_method :vetfort_offline_order_tabs, :vetfort_offline_order_actions

    before_action :initialize_order_events
    # close_adjustments channel set_channel resend
    # edit update cancel resume approve open_adjustments
    before_action :load_order, only: %i[
      cart approve
    ]

    respond_to :html

    def new
      @order = scope.create(order_params)
      assign_order_to_user
      redirect_to cart_admin_spree_vetfort_offline_url(@order)
    end

    def edit
      can_not_transition_without_customer_info

      @order.refresh_shipment_rates(ShippingMethod::DISPLAY_ON_BACK_END) unless @order.completed?
    end

    def cart
      @order.refresh_shipment_rates(Spree::ShippingMethod::DISPLAY_ON_BACK_END) unless @order.completed?

      if @order.shipments.shipped.exists?
        redirect_to spree.edit_admin_spree_vetfort_offline_url(@order)
      end
    end

    def update
      if @order.update(params[:order]) && @order.line_items.present?
        @order.update_with_updater!
        unless @order.completed?
          # Jump to next step if order is not completed.
          redirect_to spree.admin_order_customer_path(@order) and return
        end
      elsif @order.line_items.empty?
        @order.errors.add(:line_items, Spree.t('errors.messages.blank'))
      end

      render action: :edit
    end

    def cancel
      @order.canceled_by(try_spree_current_user)
      flash[:success] = Spree.t(:order_canceled)
      redirect_back fallback_location: spree.edit_admin_order_url(@order)
    end

    def resume
      @order.resume!
      flash[:success] = Spree.t(:order_resumed)
      redirect_back fallback_location: spree.edit_admin_order_url(@order)
    end

    def approve
      invoke_callbacks(:create, :before)

      begin
        @payment ||= @order.payments.build(object_params)
        @payment.save
        payments = [@payment]

        if payments && (saved_payments = payments.select &:persisted?).any?
          invoke_callbacks(:create, :after)

          while @order.next; end
          saved_payments.each { |payment| payment.process! if payment.reload.checkout? && @order.complete? }
        end

        @payment.capture!

        shipment = @order.shipments.first
        change_state_service.call(shipment: shipment, state: 'ship')
        flash[:success] = Spree.t('admin.spree_vetfort.order.sold')

        redirect_to admin_orders_path
      rescue Spree::Core::GatewayError => e
        invoke_callbacks(:create, :fails)
        flash[:error] = e.message.to_s
        redirect_to new_admin_order_payment_path(@order)
      end
    end

    def resend
      @order.deliver_order_confirmation_email
      flash[:success] = Spree.t(:order_email_resent)

      redirect_back fallback_location: spree.edit_admin_order_url(@order)
    end

    def reset_digitals
      load_order
      @order.digital_links.each(&:reset!)
      flash[:notice] = Spree.t('admin.digitals.downloads_reset')

      redirect_back fallback_location: spree.edit_admin_order_url(@order)
    end

    def open_adjustments
      adjustments = @order.all_adjustments.finalized
      adjustments.update_all(state: 'open')
      flash[:success] = Spree.t(:all_adjustments_opened)

      redirect_back fallback_location: spree.admin_order_adjustments_url(@order)
    end

    def close_adjustments
      adjustments = @order.all_adjustments.not_finalized
      adjustments.update_all(state: 'closed')
      flash[:success] = Spree.t(:all_adjustments_closed)

      redirect_back fallback_location: spree.admin_order_adjustments_url(@order)
    end

    def set_channel
      if @order.update(order_params)
        flash[:success] = flash_message_for(@order, :successfully_updated)
      else
        flash[:error] = @order.errors.full_messages.join(', ')
      end

      redirect_to channel_admin_order_url(@order)
    end

    private

    def change_state_service
      Spree::Api::Dependencies.platform_shipment_change_state_service.constantize
    end

    def object_params
      {
        amount: @order.total.to_f,
        payment_method_id: Spree::PaymentMethod::Check.first.id
      }
    end

    def assign_order_to_user
      user = Spree::User.admin.first
      address_attrs = %i[firstname lastname address1 address2 city country_id zipcode  phone state_name company]
      address = user.billing_address&.slice(*address_attrs)

      attributes = {
        email: user.email,
        user_id: user.id,
        use_billing: :t,
        bill_address_attributes: address,
        ship_address_attributes: address
      }

      @order.update(attributes)
      @order.associate_user!(user, @order.email.blank?)
    end

    def scope
      current_store.orders.accessible_by(current_ability, :index)
    end

    def order_params
      params[:created_by_id] = try_spree_current_user.try(:id)
      params.permit(:created_by_id, :user_id, :store_id, :channel)
    end

    def load_order
      @order = scope.includes(:adjustments).find_by!(number: params[:id])
      authorize! action, @order
    end

    # Used for extensions which need to provide their own custom event links on the order details view.
    def initialize_order_events
      @order_events = %w{approve cancel resume}
    end

    def model_class
      Spree::Order
    end
  end
end
