class AddressSerializer < Serializer
  attributes :id, :line1, :line2, :city, :phone_number1, :phone_number2
  belongs_to :country
end
