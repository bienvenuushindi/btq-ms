# frozen_string_literal: true
module RequisitionService
  class Reader < BaseService::Reader
    def initialize(resource_id)
      super(Requisition, resource_id)
    end

    def self.find_by_date(params, scope = Requisition.all)
      date = parse_date(params[:date])
      scope.find_by(date: date)
    rescue ArgumentError => e
      raise ArgumentError, 'Invalid date format'
    end

    private

    def self.parse_date(date_param)
      Date.parse(date_param)
    end
  end
end
