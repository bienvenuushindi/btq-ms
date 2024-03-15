module JsonResponseHelper
  extend ActiveSupport::Concern

  def completed_response(message = '')
    {
      status: { code: 200, message: message }
    }
  end

  def fetch_response(data)
    {
      status: { code: 200 },
      data: data
    }
  end

  def created_response(data, message = "Created successfully")
    {
      status: { code: 201, message: message },
      data: data
    }
  end

  def unauthorized_response(message = 'Not Authorized')
    {
      status: { code: 401, message: message }
    }
  end

  def error_response(instance, message = nil)
    message = "#{instance.class.name} couldn't be created successfully. #{instance.errors.full_messages.to_sentence}" if message.nil?
    {
      status: { code: 422, message: message }
    }
  end
end
