# frozen_string_literal: true
module CountryService
class Reader < BaseService::Reader
  def initialize(resource_id)
    super(Country, resource_id)
  end
end
end