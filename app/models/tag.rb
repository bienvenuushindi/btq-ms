class Tag < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: %i[name], using: { tsearch: { prefix: true } }
  has_many :suppliers
end
