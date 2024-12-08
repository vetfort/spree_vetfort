module Spree::Admin::SpreeVetfort
  class PropertiesTranslationsController < Spree::Admin::BaseController
    before_action :load_product

    def update
      @product.product_properties.each do |product_property|
        current_store.supported_locales_list.sort.each do |locale|
          translation_params = params[:product_properties][product_property.id.to_s]
                                .dig("translations", locale)
                                &.permit(:value)
                                &.to_h

          if translation_params.present?
            Mobility.with_locale(locale) do
              product_property.value = translation_params["value"]
              product_property.save
            end
          end
        end
      end

      redirect_to admin_product_path(@product)
    end

    private

    def load_product
      @product = Spree::Product.find_by(slug: params[:id])
    end
  end
end
