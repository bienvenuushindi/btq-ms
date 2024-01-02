module UtilitiesHelper
  extend ActiveSupport::Concern

  def update_attribute(model_instance, attribute_name, new_value)
    case attribute_name.to_sym
    when :tags
      model_instance.tag_list = new_value
    when :images
      update_images(model_instance, new_value)
    when :address
      update_address(model_instance, new_value)
    else
      model_instance.update(attribute_name => new_value)
    end
  end
  private

  def update_address(model_instance, params)
    # Create or find the Country object
    country = Country.find_or_create_by(code: params[:country_id]) do |c|
      c.name = params[:country_name]
    end

    address_params = {
      line1: params[:address1],
      city: params[:city],
      phone_number1: params[:tel1],
      phone_number2: params[:tel2],
      line2: params[:address2],
      country_id: country.id
    }

    address = model_instance.address
    address.update!(address_params)
  end

  def update_images(model_instance, new_images)
    return unless new_images.present?

    existing_images = new_images.select { |image| image.instance_of?(String) }

    # Purge images that were not kept
    images_to_purge = model_instance.images.reject do |attachment|
      existing_images.any? { |item| item.include?(attachment_blob_url(attachment)) }
    end

    images_to_purge.each(&:purge)

    new_images.each do |image|
      model_instance.images.attach(image) unless image.instance_of?(String)
    end
  end

  def attachment_blob_url(attachment)
    Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true)
  end
end