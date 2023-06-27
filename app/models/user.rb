class User < ApplicationRecord
  belongs_to :role
  has_many :products
  has_many :requisitions
  has_many :addresses, as: :addressable
  has_many :suppliers

end
