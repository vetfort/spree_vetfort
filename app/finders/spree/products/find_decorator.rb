module Spree::Products::FindDecorator
  def by_properties(products)
    return products unless properties?

    product_ids = []
    index = 0

    properties.to_unsafe_hash.each do |property_filter_param, product_properties_values|
      next if property_filter_param.blank? || product_properties_values.empty?

      # Handle both string and array inputs
      values = if product_properties_values.is_a?(String)
                 product_properties_values.split(',')
               else
                 Array(product_properties_values)
               end

      # Parameterize each individual value
      values = values.reject(&:empty?).uniq.map { |value| value.to_s.parameterize }
      next if values.empty?

      ids = scope.unscope(:order, :includes).with_property_values(property_filter_param, values).ids
      product_ids = index == 0 ? ids : product_ids & ids
      index += 1
    end

    products.where(id: product_ids)
  end
end

Spree::Products::Find.prepend(Spree::Products::FindDecorator)
