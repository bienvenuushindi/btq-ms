class Requisition < ApplicationRecord
  belongs_to :user
  has_many :product_detail_requisitions
  has_many :products, through: :product_detail_requisitions
end
