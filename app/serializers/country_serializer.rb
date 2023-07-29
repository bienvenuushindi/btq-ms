class CountrySerializer
  include JSONAPI::Serializer
  attributes :id, :name, :code
  has_many :suppliers
end
