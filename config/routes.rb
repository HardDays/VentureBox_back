Rails.application.routes.draw do
  resources :company_items, only: [:index, :show] do
    member do
      get :item_image, path: "image"
    end
  end

  resources :companies, only: [:show]
  resources :users do
    resources :companies, only: [:create, :update, :destroy] do
      resources :company_items do
        collection do
          get :my_items, path: ""
        end
        member do
          get :my_item, path: ""
        end
      end
    end
  end

  resources :authentication, path: "auth", only: [] do
    collection do
      post :login
      post :forgot_password
      post :logout
    end
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
end
