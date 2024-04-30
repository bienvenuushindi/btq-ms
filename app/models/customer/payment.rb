class Customer::Payment < ApplicationRecord
  belongs_to :individual_order
end
