class Categorization < ApplicationRecord
  belongs_to :categorizable, polymorphic: true
  belongs_to :category
  belongs_to :supplier,  -> { where(categorizations: { categorizable_type: 'Supplier' }) }, foreign_key: 'categorizable_id'
  belongs_to :product, -> { where(categorizations: { categorizable_type: 'Product' }) }, foreign_key: 'categorizable_id'
end
