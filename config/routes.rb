Rails.application.routes.draw do
  resources :enums, only: [] do
    collection do
      get :c_level
      get :stage_of_funding
      get :tags
    end
  end

  resources :tracking, only: [] do
    collection do
      get :startup
      get :investor
    end
  end

  resources :interesting_companies, only: [:index]

  resources :invested_companies, only: [:index]

  resources :startup_news, only: [:index]

  resources :company_items, only: [:index, :show] do
    member do
      get :item_image, path: "image"
    end
  end

  resources :companies, only: [:index, :show] do
    collection do
      get :investor_companies, path: "my"
    end
    member do
      get :image

      resources :company_items, only: [] do
        collection do
          get :company_items, path: ""
        end
      end

      resources :startup_news, path: "company_news", only: [] do
        collection do
          get :company_news, path: ""
        end
      end

      resources :invested_companies, only: [:create]
      resources :interesting_companies, only: [:create] do
        collection do
          delete :destroy
        end
      end
    end
  end

  resources :users, except: [:index, :update, :show] do
    collection do
      get :me
    end
    member do
      patch :change_password
      patch :change_email
      patch :change_general
    end

    resources :investor_graphics, only: [] do
      collection do
        get :total_current_value
        get :amount_invested
        get :rate_of_return
      end
    end

    resources :companies, only: [:update] do
      member do
        get :my, path: ""
        get :my_image, path: "image"

        resources :invested_companies, path: "investors", only: [] do
          collection do
            get :my_investors, path: ""
          end
        end
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
      end

      resources :milestones, only: [:index, :show, :create, :update]

      resources :startup_graphics, only: [] do
        collection do
          get :sales
          get :total_investment
          get :total_earn
          get :score
          get :evaluation
        end
      end

      resources :google_events, only: [:index, :create] do
        collection do
          post :set_google_calendar
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
