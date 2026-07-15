class Requisition < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[date], using: { tsearch: { prefix: true } }
  belongs_to :user
  has_many :product_detail_requisitions
  has_many :product_details, through: :product_detail_requisitions

  scope :archived, -> { where(archived: true) }
  scope :active, -> { where(archived: [false, nil]) }
  scope :most_recent_archived, -> { archived.order(created_at: :desc).limit(1) }
  scope :most_recent_active, -> { active.order(created_at: :desc).limit(1) }
  scope :visible_to, lambda { |user|
    if user&.admin?
      all
    elsif user&.supplier?
      where(user_id: user.id)
    elsif user
      where(user_id: user.id)
    else
      none
    end
  }

  before_validation do
    self.total_price = total_price.present? ? total_price.to_d.round(2) : 0
  end

  def self.by_status(status)
    case status.to_s
    when 'true', 'archived'
      archived
    when 'false', 'not_archived', 'active'
      where(archived: [false, nil])
    else
      all
    end
  end

  def self.most_recent_requisitions(scope = all)
    archived_result = scope.archived.order(created_at: :desc).first
    active_result = scope.active.order(created_at: :desc).first

    { active: active_result || {}, archived: archived_result || {} }
  end

  def purchased_total_price
    product_detail_requisitions
      .bought
      .sum('COALESCE(quantity, 0) * COALESCE(price, 0)')
      .to_d
      .round(2)
  end

  def recalculate_purchased_total_price!
    update_column(:total_price, purchased_total_price)
  end

end
