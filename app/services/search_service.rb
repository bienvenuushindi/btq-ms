module SearchService
  class << self
    def search_records(scope, query, options = {})
      return scope.none if scope.nil? || query.nil? || query.empty?

      records = scope.search(query)
      apply_options(records, options)
    rescue => e
      Rails.logger.error("Error searching records: #{e.message}")
      scope.none
    end

    private

    def apply_options(records, options)
      options.each do |key, value|
        case key
        when :limit
          records = records.limit(value)
        when :order
          records = records.order(value)
        when :page
          records = records.paginate(page: value, per_page: options[:per_page])
        else
          # type code here
        end
      end

      records
    end
  end
end
