module JsonResponseHelper
  extend ActiveSupport::Concern

  def completed_response(message = '')
    {
      # status: { code: 200, message: },
    }
  end

  def fetch_response(data)
      # status: { code: 200 },
      data
  end

  def created_response(data, message = "Created successfully")
    # message = "#{data.class.name} #{message}" unless message
    # {
      # status: { code: 201, message: },
      data
  end

  def unauthorized_response(message = 'Not Authorized')
    {
      status: { code: 401, message: },
    }
  end

  def error_response(instance)
    message = "#{instance.class.name} couldn't be created successfully. #{instance.errors.full_messages.to_sentence}"
    {
      status: { code: 422, message: }
    }
  end
end
