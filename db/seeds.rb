# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# --- Configuration ---
require_relative 'seeds/shop_master_product_catalog'
puts "📥 Importing shop catalog without clearing existing records..."
puts "--------------------------------------------------"

# --- 1. Roles ---
puts "⚙️ Creating Roles..."
admin_role = Role.find_or_create_by!(name: 'Admin')
supplier_role = Role.find_or_create_by!(name: 'Supplier')
customer_role = Role.find_or_create_by!(name: 'Customer')
puts "✅ Roles created: Admin, Supplier, Customer"

# --- 2. Countries ---
puts "🌍 Creating Countries..."
COUNTRIES = [
  { name: 'Democratic Republic of the Congo', code: 'CD' },
  { name: 'Republic of the Congo', code: 'CG' },
  { name: 'Rwanda', code: 'RW' },
  { name: 'Uganda', code: 'UG' },
  { name: 'Zambia', code: 'ZM' }
]
COUNTRIES.each { |attributes| Country.find_or_create_by!(code: attributes[:code]) { |country| country.name = attributes[:name] } }
puts "✅ Countries created."

# --- 3. Users ---
puts "🧑‍💻 Keeping existing Users..."
users = User.includes(:role).to_a
puts "✅ Created #{users.count} Users."

# --- 4. Supplier profiles ---
puts "🏢 Creating supplier profiles..."
suppliers = []
users.select { |u| u.role.name == 'Supplier' }.each do |user|
  supplier = Supplier.find_or_create_by!(user: user) do |record|
    record.shop_name = user.name.presence || "Supplier #{user.id}"
  end
  suppliers << supplier
end
puts "✅ Found or created #{suppliers.count} supplier profiles."

# The workbook belongs to a dedicated Usobajed supplier account. Never rename
# an unrelated supplier to claim these prices; provision the account when it
# does not already exist.
catalog_shop_name = 'Usobajed'
catalog_supplier = suppliers.find { |supplier| supplier.shop_name.to_s.casecmp(catalog_shop_name).zero? }
if catalog_supplier.nil?
  catalog_email = ENV.fetch('USOBAJED_EMAIL', 'usobajed@example.com').strip.downcase
  catalog_phone_number = ENV.fetch('USOBAJED_PHONE_NUMBER', '243995007529').strip
  catalog_password = ENV.fetch('USOBAJED_PASSWORD', '123456')
  catalog_user = User.find_or_initialize_by(email: catalog_email)
  if catalog_user.persisted? && catalog_user.role&.name.to_s.casecmp('Supplier') != 0
    raise "USOBAJED_EMAIL belongs to a non-supplier user; use a dedicated supplier email."
  end
  catalog_user.assign_attributes(
    name: catalog_user.name.presence || catalog_shop_name,
    phone_number: catalog_phone_number,
    role: supplier_role,
    active: true
  )
  catalog_user.password = catalog_password unless catalog_user.persisted?
  catalog_user.save!
  catalog_supplier = Supplier.find_or_create_by!(user: catalog_user) { |record| record.shop_name = catalog_shop_name }
  suppliers << catalog_supplier
end
puts "✅ Usobajed supplier is ready to receive catalog prices."

# --- 5. Categories ---
puts "🏷️ Creating Categories..."
main_categories = []
CATALOG_CATEGORY_DESCRIPTIONS.each do |name, description|
  category = Category.find_or_initialize_by(name: name)
  category.update!(description: description, active: true)
  main_categories << category
end

all_categories = main_categories
puts "✅ Created #{all_categories.count} Categories."

# --- 6. Products, ProductDetails & source prices ---
puts "📦 Importing the shop master product catalog..."
admin_user = users.find { |user| user.role.name.casecmp('Admin').zero? }
raise 'Create an Admin user before importing the public catalog.' unless admin_user

normalized_name = ->(value) { value.to_s.unicode_normalize(:nfkc).strip.downcase.gsub(/\s+/, ' ') }
grouped_items = CATALOG_ITEMS.group_by { |item| [item[:category], normalized_name.call(item[:name])] }
name_group_counts = grouped_items.keys.group_by(&:last).transform_values(&:length)
products = []
product_details = []
catalog_price_count = 0
catalog_unpriced_count = 0

grouped_items.each do |(category_name, name_key), source_rows|
  original_name = source_rows.first[:name]
  product_name = name_group_counts[name_key] > 1 ? "#{original_name} (#{category_name})" : original_name
  base_product_name = product_name
  collision = 0
  loop do
    product = Product.find_by(name: product_name)
    break if product.nil? || product.description.to_s.include?('Imported from Shop_Master_Product_Catalog.xlsx')

    collision += 1
    suffix = collision == 1 ? 'Shop Catalog' : "Shop Catalog #{collision}"
    product_name = "#{base_product_name} (#{suffix})"
  end
  product ||= Product.new(name: product_name)
  product.assign_attributes(
    name: product_name,
    short_description: "#{category_name} product listed in the shop master catalog.",
    description: [
      'Imported from Shop_Master_Product_Catalog.xlsx.',
      CATALOG_CATEGORY_DESCRIPTIONS.fetch(category_name),
      "Catalog name: #{original_name}.",
      "Country of manufacture was not provided in the source catalog; verify it on the package.",
      *source_rows.filter_map { |row| "Source row #{row[:source_row]} price as listed: #{row[:price]}" if row[:price].include?('/') },
      *source_rows.filter_map { |row| "Supplier note: #{row[:notes]}" if row[:notes].present? }
    ].uniq.join("\n"),
    approval_status: :approved,
    catalog_scope: :public_catalog,
    country_origin: 'Not specified',
    user: admin_user,
    submitted_by: admin_user,
    reviewed_by: admin_user,
    reviewed_at: Time.current
  )
  product.save!
  products << product
  Categorization.find_or_create_by!(categorizable: product, category: main_categories.find { |category| category.name == category_name })

  variants = source_rows.flat_map do |row|
    primary_size = row[:size].blank? || row[:size] == '—' ? 'Size not specified' : row[:size]
    primary_price = catalog_price(row[:price])
    values = [{ size: primary_size, price: primary_price, source_row: row[:source_row] }]
    values.concat(catalog_note_variants(row[:notes]).map { |variant| variant.merge(source_row: row[:source_row]) })
    values
  end

  variants_by_size = variants.group_by { |variant| normalized_name.call(variant[:size]) }
  variants_by_size.each_value do |same_size_variants|
    seen_price_keys = []
    same_size_variants.each do |variant|
      size = variant[:size]
      price = variant[:price]
      price_key = price && [price[:amount].to_s('F'), price[:currency]]
      next if seen_price_keys.include?(price_key)

      if seen_price_keys.any?
        # PostgreSQL permits one detail per normalized size. Keep conflicting
        # source listings separately identifiable instead of dropping a price.
        size = "#{size} (catalog row #{variant[:source_row]})"
      end
      seen_price_keys << price_key

      detail = product.product_details.where('LOWER(BTRIM(size)) = ?', normalized_name.call(size)).first_or_initialize
      detail.assign_attributes(
        size: size,
        dozen_units: 0,
        box_units: 0,
        approval_status: :approved,
        status: true,
        submitted_by: admin_user,
        views: detail.new_record? ? 0 : detail.views,
        sales_count: detail.new_record? ? 0 : detail.sales_count,
        reviewed_by: admin_user,
        reviewed_at: Time.current
      )
      detail.save!
      product_details << detail
      supplier_product_detail = SupplierProductDetail.find_or_initialize_by(supplier: catalog_supplier, product_detail: detail)
      supplier_product_detail.update!(supplier_status: true)

      if price
        price_detail = PriceDetail.find_or_initialize_by(supplier: catalog_supplier, product_detail: detail, quantity_type: :unit)
        price_detail.update!(price: price[:amount], currency: price[:currency], supplier_status: true)
        catalog_price_count += 1
      else
        catalog_unpriced_count += 1
      end
    end
  end
end
puts "✅ Imported #{products.count} products, #{product_details.count} pack variants, #{catalog_price_count} prices, and #{catalog_unpriced_count} unpriced variants."

# Make each shop's selected categories reflect the products it actually sells.
suppliers.each do |supplier|
  category_ids = supplier.product_details.joins(product: :categories).distinct.pluck('categories.id')
  Category.where(id: category_ids).find_each do |category|
    supplier.categorizations.find_or_create_by!(category: category)
  end
end
puts "✅ Assigned selling categories to supplier shops."

# The previous demo catalog created empty food categories. Deactivate only
# those legacy categories when nothing in the live database still uses them.
[
  'Rice, grains & flour', 'Cooking essentials', 'Canned & preserved foods', 'Beverages',
  'Dairy, eggs & chilled', 'Snacks & confectionery', 'Personal care', 'Household cleaning',
  'Baby care', 'Fresh produce'
].each do |legacy_name|
  legacy_category = Category.find_by(name: legacy_name)
  next unless legacy_category
  next if legacy_category.products.exists? || legacy_category.suppliers.exists? || legacy_category.customer_preferences.exists?

  legacy_category.update!(active: false)
end

quantity_types = %w[unit dozen box]

# --- 8. Optional demo data (Carts, Orders, Reviews, Requisitions) ---
if ENV['RUN_DEMO_SEEDS'] == 'true'
puts "🛒 Creating demo Customer Data (Carts, Orders, Reviews)..."
customer_users = users.select { |u| u.role.name == 'Customer' }
order_statuses = %w[pending processing shipped delivered cancelled]
payment_methods = %w[credit_card paypal bank_transfer]

customer_users.each do |user|
  # Customer Preferences
  Customer::Preference.create!(
    user: user,
    category: all_categories.sample
  )

  Customer::PricePreference.create!(
    user: user,
    price_types: quantity_types.sample(rand(1..3))
  )

  # Customer Carts
  if [true, false].sample
    cart = Customer::Cart.create!(user: user, status: true, total_amount: 0)
    product_details.sample(rand(1..5)).each do |detail|
      Customer::CartItem.create!(
        customer_cart_id: cart.id,
        product_detail: detail,
        quantity: rand(1..20),
        quantity_type: quantity_types.sample
      )
    end
    cart_items = Customer::CartItem.where(customer_cart_id: cart.id)
    cart.update(total_amount: cart_items.sum { |item| item.quantity * (item.product_detail.price_details.unit.first&.price || 0) })
  end

  # Individual Orders
  rand(0..2).times do
    order = Customer::IndividualOrder.create!(
      user: user,
      total_amount: 0,
      status: order_statuses.sample,
      delivery_date: Faker::Date.forward(days: 10)
    )

    # Order Details & Combined Order
    combined_total = rand(10..500)
    combined_order = Customer::CombinedOrder.create!(
      product_detail: product_details.sample,
      status: order.status,
      quantity: rand(1..5),
      quantity_type: quantity_types.sample,
      total_amount: combined_total
    )

    Customer::OrderDetail.create!(
      customer_individual_order_id: order.id,
      product_detail: product_details.sample,
      customer_combined_order_id: combined_order.id,
      quantity: rand(1..10),
      quantity_type: quantity_types.sample
    )

    order.update(total_amount: combined_order.total_amount)

    # Payment
    if order.status != 'pending'
      Customer::Payment.create!(
        customer_individual_order_id: order.id,
        amount_paid: order.total_amount,
        method: payment_methods.index(payment_methods.sample).to_s,
        status: ['completed', 'failed'].sample
      )
    end

    # Shipping
    user_addresses = user.addresses
    if user_addresses.present?
      Customer::Shipping.create!(
        customer_individual_order_id: order.id,
        address: user_addresses.sample
      )
    end
  end

  # Customer Ratings and Reviews
  product_details.sample(rand(0..3)).each do |detail|
    Customer::Rating.create!(
      user: user,
      product_detail: detail,
      score: rand(1..5)
    )

    Customer::Review.create!(
      user: user,
      product_detail: detail,
      rating: rand(1..5),
      comment: %w[Great Nice Useful Solid Fresh].sample
    )
  end
end
puts "✅ Customer data created."
end

def build_requisition_with_items!(user:, suppliers:, product_details:, quantity_types:, date:, archived:)
  requisition = Requisition.create!(
    user: user,
    total_price: 0.0,
    count_products: 0,
    count_products_bought: 0,
    price_currency: %w[usd fc ugx rw].sample,
    date: date,
    archived: archived
  )

  total_price = 0.to_d
  products_bought = 0
  products_count = 0

  product_details.sample(rand(2..5)).each do |detail|
    linked_supplier = detail.suppliers.sample || suppliers.sample
    linked_price_detail = PriceDetail.find_by(supplier: linked_supplier, product_detail: detail)
    price = (linked_price_detail&.price || Faker::Commerce.price(range: 1.0..50.0)).to_d.round(2)
    quantity = rand(10..100)
    status = [0, 1].sample

    ProductDetailRequisition.create!(
      requisition: requisition,
      product_detail: detail,
      supplier: linked_supplier,
      buyer_supplier: user.suppliers.order(:id).first,
      status: status,
      quantity: quantity,
      quantity_type: quantity_types.sample,
      price: price,
      currency: requisition.price_currency,
      expired_date: Faker::Date.forward(days: 180),
      note: Faker::Lorem.sentence
    )

    total_price += price * quantity
    products_count += 1
    products_bought += 1 if status == 1
  end

  requisition.update!(
    total_price: total_price.round(2),
    count_products: products_count,
    count_products_bought: products_bought
  )

  requisition
end

if ENV['RUN_DEMO_SEEDS'] == 'true'
  procurement_user = suppliers.first&.user || users.find { |user| %w[Admin Supplier].include?(user.role.name) }
  if procurement_user
    5.times do
      build_requisition_with_items!(
        user: procurement_user,
        suppliers: suppliers,
        product_details: product_details,
        quantity_types: quantity_types,
        date: Faker::Date.backward(days: 30),
        archived: [true, false].sample
      )
    end

    build_requisition_with_items!(
      user: procurement_user,
      suppliers: suppliers,
      product_details: product_details,
      quantity_types: quantity_types,
      date: Date.current,
      archived: nil
    )
    puts "✅ Demo requisitions created."
  else
    puts "⚠️ Skipping demo requisitions: No Admin or Supplier user found."
  end
else
  puts "Skipping demo customer records and requisitions (set RUN_DEMO_SEEDS=true to opt in)."
end

# --- Final Tally ---
puts "--------------------------------------------------"
puts "✨ Seeding Complete! Data Tally:"
puts "Roles: #{Role.count}"
puts "Countries: #{Country.count}"
puts "Users: #{User.count}"
puts "Suppliers: #{Supplier.count}"
puts "Categories: #{Category.count}"
puts "Products: #{Product.count}"
puts "Product Details: #{ProductDetail.count}"
puts "Price Details: #{PriceDetail.count}"
puts "Customer Orders: #{Customer::IndividualOrder.count}"
puts "Customer Carts: #{Customer::Cart.count}"
puts "Customer Reviews: #{Customer::Review.count}"
puts "Requisitions: #{Requisition.count}"
