class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    record.errors.add attribute, (options[:message] || 'is not an email')
  end
end

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self
  belongs_to :role
  has_many :products
  has_many :requisitions
  has_many :addresses, as: :addressable
  has_many :suppliers
  has_one_attached :image

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, email: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  def image_url
    return [ActionController::Base.helpers.image_url('no-img.png')] unless image.attached?
    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end
end
