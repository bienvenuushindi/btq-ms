class Requisition < ApplicationRecord
  belongs_to :user
  has_many :product_details
end
