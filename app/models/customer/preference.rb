class Customer::Preference < ApplicationRecord
  belongs_to :user
  belongs_to :category

  after_create :increment_category_preference_count
  after_destroy :decrement_category_preference_count

  private
  def increment_category_preference_count
    category.increment!(:preference_count)
  end

  def decrement_category_preference_count
    category.decrement!(:preference_count)
  end
end