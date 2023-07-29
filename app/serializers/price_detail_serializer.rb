class PriceDetailSerializer
  include JSONAPI::Serializer
  attributes :id, :box, :dozen, :currency

  belongs_to :product_detail
  belongs_to :supplier
end
