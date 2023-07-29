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
  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :roles, only: [:index, :create, :show]
      resources :tags, only: [:index, :create, :show]
      resources :countries, only: [:index, :create, :show]
      resources :countries, only: [] do
        resources :suppliers, only: [:index]
      end
      resources :categories, only: [:index, :create, :show]
      resources :products, only: [:index, :create, :show]
      resources :products, only: [] do
        resources :product_details, only: [:index, :create]
      end
      resources :product_details, only: [] do
        resources :price_details, only: [:index, :create, :show]
      end
      resources :requisitions, only: [:index, :create, :show]
      resources :suppliers, only: [:index, :create, :show]
      resources :addresses, only: [:index, :create, :show]
      resources :users, only: [:index, :show]
    end
  end
end
