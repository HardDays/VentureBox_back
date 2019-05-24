Rails.application.routes.draw do
  resources :startup_news, only: [:index, :show]
  resources :company_items, only: [:index, :show] do
    member do
      get :item_image, path: "image"
    end
  end

  resources :companies, only: [:index, :show] do
    member do
      get :image
    end
  end
  resources :users, except: [:index] do
    resources :companies, only: [:create, :update, :destroy] do
      member do
        get :my, path: ""
        get :my_image, path: "image"
      end
      resources :company_items, only: [:create, :update, :destroy]  do
        collection do
          get :my_items, path: ""
        end
        member do
          get :my_item, path: ""
          get :my_item_image, path: "image"
        end
      end
      resources :startup_news, only: [:create, :destroy] do
        collection do
          get :my_news, path: ""
        end
        member do
          get :my, path: ""
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
