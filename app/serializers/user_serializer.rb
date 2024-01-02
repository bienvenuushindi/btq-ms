class UserSerializer < Serializer
  include JSONAPI::Serializer
  attributes :id, :email, :name, :phone_number, :image_url
end
