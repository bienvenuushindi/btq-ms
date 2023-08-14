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
      paginator.call(collection, params: pagination_params, base_url: request.url)
    end
  
    def render_collection(paginated, opt=nil)
      options = {
        meta: paginated.meta.to_h, # Will get total pages, total count, etc.
        links: paginated.links.to_h
      }
      options = options.merge(opt) unless opt.nil?
      paginated_result = serializer.new(paginated.items, options)
  
      render json: paginated_result,  status: :ok
    end
end