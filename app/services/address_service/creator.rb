module AddressService
  class Creator < Base::Creator
    def initialize(params, record, country)
      @record = record
      @country = country
      super(params)
    end

    private
    def create_record
      Address.create!(
        line1: @params[:address1],
        line2: @params[:address2],
        city: @params[:city],
        phone_number1: @params[:tel1],
        phone_number2: @params[:tel2],
        country: @country,
        addressable: @record
      )
    end
  end
end
