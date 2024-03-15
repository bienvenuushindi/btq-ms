class Requisition < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[date], using: { tsearch: { prefix: true } }
  belongs_to :user
  has_many :product_detail_requisitions
  has_many :product_details, through: :product_detail_requisitions

  scope :archived, -> { where(archived: true) }
  scope :active, -> { where(archived: nil) }
  scope :most_recent_archived, -> { archived.order(created_at: :desc).limit(1) }
  scope :most_recent_active, -> { active.order(created_at: :desc).limit(1) }

  scope :select_home_result, -> { select(:id, :total_price, :count_products_bought, :count_products, :price_currency, :date) }

  def self.most_recent_requisitions
    archived_result = most_recent_archived&.select_home_result&.first
    active_result = most_recent_active&.select_home_result&.first

    { active: active_result || {}, archived: archived_result || {} }
  end


end
