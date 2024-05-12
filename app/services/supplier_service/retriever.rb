# frozen_string_literal: true
module SupplierService
class Retriever < BaseService::Retriever
  def initialize(scope, filter_params)
    @sort_column = %w[shop_name created_at]
    super(scope, filter_params)
  end

  def call
    super
    attach_images_to_result
  end

  private
  def attach_images_to_result
    @scope.with_attached_images
  end
end
end