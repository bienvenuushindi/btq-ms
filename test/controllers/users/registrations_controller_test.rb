require 'test_helper'
require 'minitest/mock'

class Users::RegistrationsControllerTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test 'account updates cannot change roles' do
    controller = Users::RegistrationsController.new
    controller.params = ActionController::Parameters.new(
      user: {
        email: 'supplier@example.com',
        role_id: 999,
        password: 'new-password',
        password_confirmation: 'new-password'
      }
    )

    permitted = controller.send(:account_update_params)

    refute permitted.key?(:role_id)
    assert_equal 'new-password', permitted[:password]
    assert_equal 'new-password', permitted[:password_confirmation]
  end

  test 'public signup cannot choose a privileged role' do
    customer_role = Struct.new(:id).new(3)
    Role.stub(:find_by, customer_role) do
      controller = Users::RegistrationsController.new
      controller.params = ActionController::Parameters.new(
        user: {
          email: 'customer@example.com',
          password: 'password',
          name: 'Customer',
          phone_number: '123',
          role_id: 1
        }
      )

      permitted = controller.send(:sign_up_params)

      assert_equal 3, permitted[:role_id]
    end
  end
end
