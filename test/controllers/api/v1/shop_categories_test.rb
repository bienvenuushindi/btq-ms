ENV['RAILS_ENV'] ||= 'test'
require_relative '../../../../config/environment'
require 'rails/test_help'

class ShopCategoriesTest < ActionDispatch::IntegrationTest
  setup do
    role = Role.create!(name: 'supplier')
    @owner = User.create!(name: 'Shop owner', email: 'categories-owner@example.com', password: 'password123', phone_number: '123456789', role: role, active: true)
    @shop = Supplier.create!(shop_name: 'Category shop', user: @owner)
    other = User.create!(name: 'Other owner', email: 'categories-other@example.com', password: 'password123', phone_number: '123456789', role: role, active: true)
    @other_shop = Supplier.create!(shop_name: 'Other shop', user: other)
    @category = Category.create!(name: 'Food', description: 'Food category', active: true)
    @other_category = Category.create!(name: 'Drinks', description: 'Drinks category', active: true)
    token, = Warden::JWTAuth::UserEncoder.new.call(@owner, :user, nil)
    @headers = { 'Authorization' => "Bearer #{token}" }
  end

  test 'selection is saved, idempotent and scoped to the current shop' do
    2.times do
      post "/api/v1/categories/shop/#{@category.id}", headers: @headers
      assert_response :success
    end
    assert_equal 1, @shop.categorizations.where(category: @category).count
    assert_empty @other_shop.categories
    get '/api/v1/categories/shop', headers: @headers
    assert_response :success
    assert_equal [@category.id], response.parsed_body['data'].map { |category| category['id'] }
    assert_not response.parsed_body['data'].first.key?('children')
  end

  test 'removing a category keeps the catalog and selected products' do
    product, detail = catalog_product(@category, 'Rice')
    @shop.categories << @category
    selection = SupplierProductDetail.create!(supplier: @shop, product_detail: detail, supplier_status: true, expired_date: detail.expired_date)
    @other_shop.categories << @category
    delete "/api/v1/categories/shop/#{@category.id}", headers: @headers
    assert_response :no_content
    assert_empty @shop.categories.reload
    assert @other_shop.categories.reload.include?(@category)
    assert Category.exists?(@category.id)
    assert Product.exists?(product.id)
    assert SupplierProductDetail.exists?(selection.id)
  end

  test 'inactive and missing categories cannot be selected' do
    @category.update!(active: false)
    post "/api/v1/categories/shop/#{@category.id}", headers: @headers
    assert_response :not_found
    post '/api/v1/categories/shop/0', headers: @headers
    assert_response :not_found
    assert_empty @shop.categories
  end

  test 'admin cannot select shop categories and owner cannot create catalog categories' do
    admin = User.create!(name: 'Admin', email: 'categories-admin@example.com', password: 'password123', phone_number: '123456789', role: Role.create!(name: 'admin'), active: true)
    token, = Warden::JWTAuth::UserEncoder.new.call(admin, :user, nil)
    post "/api/v1/categories/shop/#{@category.id}", headers: {'Authorization' => "Bearer #{token}"}
    assert_response :forbidden
    post '/api/v1/categories', params: {category: {name: 'New', description: 'New category'}}, headers: @headers
    assert_response :forbidden
  end

  test 'market filters by selected categories and excludes selected variants' do
    product, detail = catalog_product(@category, 'Rice')
    catalog_product(@other_category, 'Water')
    get '/api/v1/products/market', params: {shop_categories: true}, headers: @headers
    assert_response :success
    assert_empty response.parsed_body['data']
    @shop.categories << @category
    get '/api/v1/products/market', params: {shop_categories: true, category_id: @category.id}, headers: @headers
    assert_response :success
    assert_equal [product.id], response.parsed_body['data'].map { |item| item['id'] }
    SupplierProductDetail.create!(supplier: @shop, product_detail: detail, supplier_status: true, expired_date: detail.expired_date)
    get '/api/v1/products/market', params: {shop_categories: true}, headers: @headers
    assert_response :success
    assert_empty response.parsed_body['data']
    get '/api/v1/products', params: {category_id: @category.id}, headers: @headers
    assert_response :success
    assert_equal [product.id], response.parsed_body['data'].map { |item| item['id'] }
  end

  private

  def catalog_product(category, name)
    product = Product.create!(name: name, short_description: name, country_origin: 'CG', user: @owner, approval_status: :approved)
    product.categories << category
    detail = ProductDetail.create!(product: product, size: '1 kg', expired_date: 1.year.from_now, approval_status: :approved)
    [product, detail]
  end
end
