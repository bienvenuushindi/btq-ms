# frozen_string_literal: true

class SearchService
  def search_records(scope, query, options = {})
    records = scope.search(query)
    # Apply additional options if provided
    apply_options(records, options)
  end

  private

  def apply_options(records, options)
    records = records.limit(options[:limit]) if options.key?(:limit)
    records = records.order(options[:order]) if options.key?(:order)
    records = records.paginate(page: options[:page], per_page: options[:per_page]) if options.key?(:page)

    records
  end
end
