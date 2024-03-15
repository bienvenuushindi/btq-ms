# frozen_string_literal: true

module CustomSerializer
  extend ActiveSupport::Concern

  def serialize_resource(resource, serializer_class, options = {})
    serializer_class.new(resource, options).serializable_hash[:data][:attributes]
  end

  def serialize_resources(resources, serializer_class, options = {})
    serializer_class.new(resources, options).serializable_hash[:data].map { |data| data[:attributes] }
  end
end
