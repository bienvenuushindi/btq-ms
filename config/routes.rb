Rails.application.routes.draw do
  # devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get 'products/search', to: 'products#search'
      get 'products/stats', to: 'products#count_by_status'
      get 'suppliers/search/filter/:product_detail_id', to: 'suppliers#search'
      get 'tags/search', to: 'tags#search'
      resources :roles, only: [:index, :create, :show]
      resources :tags, only: [:index, :create, :show]
      resources :countries, only: [:index, :create, :show]
      resources :countries, only: [] do
        resources :suppliers, only: [:index]
      end
      resources :categories, only: [:index, :create, :show] do
        collection do
          get 'tree_structure'
        end
      end
      resources :products, only: [] do
        resources :product_details, only: [:index, :create, :show, :update]
      end
      resources :products, only: [:index, :create, :show, :update]
      resources :product_details, only: [] do
        resources :price_details, only: [:index, :create, :show]
        collection do
          get 'expiring_soon'
          get 'expired'
        end
        member do
          get 'suppliers', to: 'product_details#suppliers'
        end
      end
      resources :requisitions, only: [:index, :create, :show, :update] do
        collection do
          get 'date/:date', to: 'requisitions#find_by_date'
        end
        member do
          delete 'product_details/:product_detail_id/remove_item', to: 'requisitions#remove_item', as: :remove_item
          post 'add_products', to: 'requisitions#add_products', as: :add_products
          put 'update_products/:product_detail_id', to: 'requisitions#update_products_list'
        end
      end
      resources :suppliers, only: [:index, :create, :show, :update]
      resources :addresses, only: [:index, :create, :show]
      resources :users, only: [:index, :show]
      resources :requisition_products, only: [] do
        member do

        end
      end
      get '/current_user', to: 'current_user#index'
      get 'quantity_types', to: 'requisition_products#quantity_types'
      get 'currencies', to: 'requisition_products#currencies'
    end
  end
end
