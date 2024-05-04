# frozen_string_literal: true
module CountryService
  class Creator < BaseService::Creator
    def initialize(params)
      super(params)
    end

    private

    def create_record
      Country.find_or_create_by(code: @params[:code]) do |country|
        country.name = @params[:name]
      end
    end
  end
end
