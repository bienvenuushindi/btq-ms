class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :name, :phone_number
end
