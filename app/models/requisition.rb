class Requisition < ApplicationRecord
  belongs_to :user
  has_many :product_requisitions
  has_many :products, through: :product_requisitions
end
