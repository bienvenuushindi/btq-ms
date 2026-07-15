module AttachmentUrlHelper
  extend ActiveSupport::Concern

  private

  def attachment_urls_or_default(attachments, default_url)
    return [default_url] unless attachments.attached?

    urls = attachments.filter_map { |attachment| safe_attachment_url(attachment) }
    urls.presence || [default_url]
  end

  def attachment_url_or_default(attachment, default_url)
    return default_url unless attachment.attached?

    safe_attachment_url(attachment) || default_url
  end

  def safe_attachment_url(attachment)
    attachment.blob.url
  rescue StandardError => error
    Rails.logger.warn(
      "Unable to generate attachment URL for #{attachment.record.class.name}##{attachment.record.id}: #{error.message}"
    )
    nil
  end
end
