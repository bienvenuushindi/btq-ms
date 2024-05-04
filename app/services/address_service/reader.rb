module AddressService
  class Reader < BaseService::Reader
    def initialize(resource_id)
      super(Address, resource_id)
    end
  end
end