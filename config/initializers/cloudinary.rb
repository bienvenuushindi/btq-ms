# frozen_string_literal: true

if Rails.application.config.active_storage.service.to_sym == :cloudinary
  require 'cloudinary'

  # Cloudinary's SDK ignores CLOUDINARY_URL when CLOUDINARY_CLOUD_NAME is also
  # present. Prefer the complete URL selected by our Active Storage config so a
  # partial set of CLOUDINARY_* variables cannot silently override valid values.
  cloudinary_url = ENV['CLOUDINARY_URL'].to_s.strip
  if cloudinary_url.length >= 2 && ['"', "'"].include?(cloudinary_url[0]) && cloudinary_url[-1] == cloudinary_url[0]
    cloudinary_url = cloudinary_url[1...-1]
  end
  Cloudinary.config_from_url(cloudinary_url) if cloudinary_url.present?

  missing = %i[cloud_name api_key api_secret].reject { |key| Cloudinary.config.public_send(key).present? }
  if missing.any?
    raise "Cloudinary storage is enabled but credentials are incomplete (missing: #{missing.join(', ')})"
  end
end
