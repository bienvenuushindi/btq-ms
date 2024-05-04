module ProductService
  class Retriever < Base::Retriever
    def initialize(scope, filter_params)
      @sort_column = %w[name active created_at country_origin]
      super(scope, filter_params)
    end

    def call
      super
      @scope.with_attached_images
    end
  end
end