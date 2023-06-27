class ProductDetailRequisition < ApplicationRecord
  belongs_to :requisition
  belongs_to :product
end
