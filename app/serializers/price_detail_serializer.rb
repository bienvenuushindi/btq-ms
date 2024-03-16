# serializers/price_detail_serializer.rb
class PriceDetailSerializer < Serializer
  attributes :id, :price, :quantity_type, :currency

  belongs_to :product_detail
  belongs_to :supplier

  class << self
    def group_by_supplier(price_details)
      price_details.group_by(&:supplier)
                   .map do |supplier, details|
        {
          supplier: SupplierSerializer.new(supplier).serializable_hash[:data][:attributes],
          price_details: details.map { |detail| new(detail).serializable_hash[:data][:attributes] }
        }
      end
    end
  end
end
