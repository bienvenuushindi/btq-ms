class CountrySerializer
  include JSONAPI::Serializer
  attributes :id, :name, :code
end
