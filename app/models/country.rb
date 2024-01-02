class Country < ApplicationRecord
  has_many :addresses, foreign_key: :country_id
  has_many :suppliers, through: :addresses, source: :addressable, source_type: 'Supplier'
  has_many :users, through: :addresses, source: :addressable, source_type: 'User'
  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
end
