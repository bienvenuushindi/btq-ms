class Api::V1::UsersController < ApplicationController
  before_action :find_user, only: %i[show]

  def index
    render json: serialize_resources(User.all, serializer), status: :ok
  end

  def show
    render json: serialize_resource(@user, serializer), status: :ok
  end

  def update
    @user = current_user

    ActiveRecord::Base.transaction do
      update_user_record!
      update_user_address!
      update_user_image!
    end

    render json: serialize_resource(@user.reload, serializer), status: :ok
  rescue ActiveRecord::RecordInvalid => e
    render json: {errors: [e.record.errors.full_messages.to_sentence]}, status: :unprocessable_entity
  end

  private

  def serializer
    UserSerializer
  end

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :phone_number,
      :address1,
      :address2,
      :city,
      :tel1,
      :tel2,
      :country_id,
      :country_name,
      images: []
    )
  end

  def update_user_record!
    @user.update!(
      name: user_params[:name],
      email: user_params[:email],
      phone_number: user_params[:phone_number].presence || user_params[:tel1]
    )
  end

  def update_user_address!
    return unless address_payload_present?

    country = CountryService::Creator.call(
      code: user_params[:country_id],
      name: user_params[:country_name]
    )

    address = @user.addresses.first_or_initialize(addressable: @user)
    address.update!(
      line1: user_params[:address1],
      line2: user_params[:address2],
      city: user_params[:city],
      phone_number1: user_params[:tel1],
      phone_number2: user_params[:tel2],
      country: country
    )
  end

  def update_user_image!
    images = Array(user_params[:images]).compact
    return if images.empty?

    latest_image = images.last
    return if latest_image.is_a?(String)

    @user.image.purge if @user.image.attached?
    @user.image.attach(latest_image)
  end

  def address_payload_present?
    %i[address1 address2 city tel1 tel2 country_id country_name].any? { |key| user_params[key].present? }
  end
end
