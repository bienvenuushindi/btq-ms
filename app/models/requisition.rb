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
  validate :exchange_rates_must_be_positive

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
      .to_a
      .sum { |item| item.quantity.to_d * item.price.to_d * exchange_multiplier(item.currency) }
      .to_d
      .round(2)
  end

  def exchange_rate_for(currency)
    source_currency = currency.to_s.downcase
    return 1.to_d if source_currency.blank? || source_currency == 'usd'

    (exchange_rates || {})[source_currency].to_d
  end

  def exchange_multiplier(currency)
    source_currency = currency.to_s.downcase
    target_currency = price_currency.to_s.downcase
    return 1.to_d if source_currency.blank? || source_currency == target_currency

    exchange_rate_for(target_currency) / exchange_rate_for(source_currency)
  end

  def exchange_rates_must_be_positive
    (exchange_rates || {}).each do |currency, rate|
      value = BigDecimal(rate.to_s) rescue nil
      unless %w[usd fc ugx rw].include?(currency.to_s.downcase) && value&.positive?
        errors.add(:exchange_rates, 'must contain positive rates for supported currencies')
        break
      end
    end
  end

  def recalculate_purchased_total_price!
    update_column(:total_price, purchased_total_price)
  end

end
