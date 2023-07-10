class Country < ApplicationRecord
  has_many :addresses
  has_many :suppliers

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
end
