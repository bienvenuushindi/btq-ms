# app/serializers/customer/price_preference_serializer.rb
class Customer::PricePreferenceSerializer < Serializer
  attributes :id, :price_types
end
