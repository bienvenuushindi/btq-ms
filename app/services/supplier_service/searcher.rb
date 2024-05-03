# frozen_string_literal: true

class Supplier_service::SearchService
  def initialize(search_service = SearchService.new)
    @search_service = search_service
  end

  def search_suppliers(query, options = {})
    scope = Supplier.includes(:address, :categories)
    options[:fields] = { supplier: [:id, :shop_name, :image_urls, :address, :categories] }

    @search_service.search_records(scope, query, options)
  end
end
