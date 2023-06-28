class Country < ApplicationRecord
  has_many :addresses
  has_many :suppliers
end
