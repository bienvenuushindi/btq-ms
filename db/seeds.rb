# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# --- Configuration ---
NUM_USERS = 50
NUM_SUPPLIERS = 10
NUM_PRODUCTS = 100
PRODUCTS_PER_SUPPLIER = 5
puts "🧹 Cleaning up existing data..."
ActiveRecord::Base.connection.disable_referential_integrity do
  [
    Customer::Shipping, Customer::Payment, Customer::OrderDetail, Customer::CombinedOrder,
    Customer::IndividualOrder, Customer::CartItem, Customer::Cart, Customer::Review,
    Customer::Rating, Customer::PricePreference, Customer::Preference, Address, Category,
    Categorization, Country, PriceDetail, ProductDetailRequisition, ProductDetail, Product,
    Requisition, Role, Supplier, Tag, User
  ].each do |model|
    model.delete_all
  rescue ActiveRecord::StatementInvalid => e
    # Catch errors for tables without data or that don't exist in the current scope
    puts "Could not delete from #{model.name}: #{e.message}"
  end
end
puts "✅ Cleanup complete."
puts "--------------------------------------------------"

# --- 1. Roles ---
puts "⚙️ Creating Roles..."
Role.create!([
  { name: 'Admin' },
  { name: 'Supplier' },
  { name: 'Customer' }
])
admin_role = Role.find_by(name: 'Admin')
supplier_role = Role.find_by(name: 'Supplier')
customer_role = Role.find_by(name: 'Customer')
puts "✅ Roles created: Admin, Supplier, Customer"

# --- 2. Countries ---
puts "🌍 Creating Countries..."
COUNTRIES = [
  { name: 'United States', code: 'US' },
  { name: 'Canada', code: 'CA' },
  { name: 'Mexico', code: 'MX' },
  { name: 'Congo, DR', code: 'CD' }
]
Country.create!(COUNTRIES)
us_country = Country.find_by(code: 'US')
puts "✅ Countries created."

# --- 3. Users ---
puts "🧑‍💻 Creating Users..."
users = []

# Admin User
users << User.create!(
  name: 'Admin User',
  email: 'admin@example.com',
  phone_number: '1111111111',
  password: 'password',
  role: admin_role
)

# Supplier Users
NUM_SUPPLIERS.times do |i|
  users << User.create!(
    name: Faker::Company.name,
    email: "supplier#{i}@example.com",
    phone_number: Faker::Number.unique.number(digits: 10),
    password: 'password',
    role: supplier_role
  )
end

# Customer Users
(NUM_USERS - NUM_SUPPLIERS - 1).times do |i|
  users << User.create!(
    name: Faker::Name.name,
    email: "customer#{i}@example.com",
    phone_number: Faker::Number.unique.number(digits: 10),
    password: 'password',
    role: customer_role
  )
end
puts "✅ Created #{users.count} Users."

# --- 4. Suppliers & Addresses ---
puts "🏢 Creating Suppliers and Addresses..."
suppliers = []
users.select { |u| u.role.name == 'Supplier' }.each do |user|
  supplier = Supplier.create!(
    user: user,
    shop_name: Faker::Company.name + ' Shop'
  )
  suppliers << supplier
  # Supplier Address
  Address.create!(
    addressable: supplier,
    country: us_country,
    line1: Faker::Address.street_address,
    city: Faker::Address.city,
    phone_number1: Faker::PhoneNumber.phone_number
  )
end

# Customer Addresses
users.select { |u| u.role.name == 'Customer' }.sample(NUM_USERS / 5).each do |user|
  Address.create!(
    addressable: user,
    country: us_country,
    line1: Faker::Address.street_address,
    city: Faker::Address.city,
    phone_number1: Faker::PhoneNumber.phone_number
  )
end
puts "✅ Created #{suppliers.count} Suppliers and multiple Addresses."

# --- 5. Categories ---
puts "🏷️ Creating Categories..."
main_categories = []
%w[Beauty Electronics Fashion Home Grocery].each do |name|
  main_categories << Category.create!(
    name: name,
    description: Faker::Lorem.sentence,
    active: true
  )
end

sub_categories = []
main_categories.each do |parent|
  3.times do |index|
    sub_categories << Category.create!(
      name: "#{parent.name} - #{Faker::Commerce.product_name.split.sample} #{index + 1}",
      description: Faker::Lorem.sentence,
      active: true,
      parent_category_id: parent.id
    )
  end
end
all_categories = main_categories + sub_categories
puts "✅ Created #{all_categories.count} Categories."

# --- 6. Products & ProductDetails ---
puts "📦 Creating Products and Product Details..."
products = []
product_details = []

NUM_PRODUCTS.times do
  creator_user = users.select { |u| u.role.name != 'Customer' }.sample
  product = Product.create!(
    name: Faker::Commerce.unique.product_name,
    short_description: Faker::Lorem.sentence(word_count: 5),
    description: Faker::Lorem.paragraph,
    approval_status: :approved,
    country_origin: COUNTRIES.sample[:code],
    user: creator_user
  )
  products << product

  # Add categorization
  product_categories = all_categories.sample(rand(1..3))
  product_categories.each do |cat|
    Categorization.create!(
      categorizable: product,
      category: cat
    )
  end

  # Create multiple product details (variants) with unique sizes per product
  ['Small', 'Medium', 'Large', 'One Size'].sample(3).each do |variant_size|
    detail = ProductDetail.create!(
      product: product,
      size: variant_size,
      expired_date: Faker::Date.forward(days: 365),
      dozen_units: 12,
      box_units: rand(50..100),
      approval_status: :approved,
      views: rand(10..500),
      sales_count: rand(0..100),
      popularity_score: rand(0.0..10.0).round(2)
    )
    product_details << detail
  end
end
puts "✅ Created #{products.count} Products and #{product_details.count} Product Details."

# --- 7. PriceDetails ---
puts "💰 Creating Price Details (Supplier Pricing)..."
suppliers.each do |supplier|
  product_details.sample(PRODUCTS_PER_SUPPLIER).each do |detail|
    PriceDetail.create!(
      supplier: supplier,
      product_detail: detail,
      price: Faker::Commerce.price(range: 1.0..50.0),
      quantity_type: :unit,
      currency: 'usd'
    )
  end
end
puts "✅ Created Price Details."

# --- 8. Customer Data (Carts, Orders, Reviews) ---
puts "🛒 Creating Customer Data (Carts, Orders, Reviews)..."
customer_users = users.select { |u| u.role.name == 'Customer' }
order_statuses = %w[pending processing shipped delivered cancelled]
payment_methods = %w[credit_card paypal bank_transfer]
quantity_types = %w[unit dozen box]

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

procurement_user = users.find { |user| %w[Admin Supplier].include?(user.role.name) }
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
  puts "✅ Requisitions created."
else
  puts "⚠️ Skipping Requisitions: No Admin or Supplier user found to assign them to."
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
