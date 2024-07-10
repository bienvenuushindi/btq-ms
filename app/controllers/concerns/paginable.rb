# app/controllers/concerns/paginable.rb
module Paginable
  extend ActiveSupport::Concern

  def paginator
    JSOM::Pagination::Paginator.new
  end

  def pagination_params
    params.permit![:page] # defaults to 20 pages
  end

  def paginate(collection)
    params = pagination_params || { number: 1, size: 10 }

    paginator.call(collection, params:, base_url: request.url)
  end

 def render_collection(paginated, serializer_class, options = {}, custom_fields = {})
  attributes = serialize_resources(paginated.items, serializer_class, options)
  pagination_options = {
    meta: paginated.meta.to_h, # Will get total pages, total count, etc.
    links: paginated.links.to_h
  }


  # Merge custom_fields with attributes and pagination_options
  result = attributes.merge(pagination_options).merge(custom_fields)

  render json: result, status: :ok
end

end
