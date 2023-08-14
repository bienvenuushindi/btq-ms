class CountrySerializer < Serializer
  attributes :id, :name, :code
  has_many :suppliers
end
