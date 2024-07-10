namespace :categories do
  desc 'Update active and inactive product counts for each category'
  task update_product_counts: :environment do
    update_category_product_counts
  end

  def update_category_product_counts
    Category.transaction do
      Category.all.each do |category|
        active_product_count = category.active_products.count
        inactive_product_count = category.inactive_products.count
        category.update_columns(
          count_products: active_product_count,
          inactive_count_products: inactive_product_count
        )
        update_parent_category_counts(category)
      end
    end
  end

  def update_parent_category_counts(category)
    return unless category.parent_category_id.present?

    parent_category = Category.find_by(id: category.parent_category_id)
    return unless parent_category

    count_products = category.count_products || 0
    inactive_count_products = category.inactive_count_products || 0

    parent_category.update_columns(
      count_products: (parent_category.count_products || 0) + count_products,
      inactive_count_products: (parent_category.inactive_count_products || 0) + inactive_count_products
    )
    update_parent_category_counts(parent_category) # Recursively update parent counts
  end

end
