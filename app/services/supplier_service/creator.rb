# frozen_string_literal: true
# app/services/supplier/creator.rb
module Services
  module Supplier
    class Creator
      def initialize(params, current_user)
        @params = params
        @current_user = current_user
      end

      def call
        create_supplier
      end

      private

      def create_supplier
        @supplier = Supplier.new(supplier_params)
        @supplier.user = @current_user
        @supplier.tag_list = @params[:tags] unless @params[:tags].blank?
        if @supplier.save
          create_country_and_address
          @supplier
        else
          handle_error
        end
      end

      def create_country_and_address
        country = Country.create_with(name: @params[:country_name]).find_or_create_by(code: @params[:country_id])
        Address.create!(
          line1: @params[:address1],
          city: @params[:city],
          country: country,
          phone_number1: @params[:tel1],
          phone_number2: @params[:tel2],
          line2: @params[:address2],
          addressable: @supplier
        )
      end

      def handle_error
        # Handle error logic, e.g., logging or raising specific exceptions
      end

      def supplier_params
        @params.require(:supplier).permit(:shop_name, :address1, :address2, :city, :tel1, :country_name, :tel2, :country_id, :tags, :categories, images: [])
      end
    end
  end
end