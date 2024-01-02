class Requisition < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[date], using: { tsearch: { prefix: true } }
  belongs_to :user
  has_many :product_detail_requisitions
  has_many :product_details, through: :product_detail_requisitions

end
