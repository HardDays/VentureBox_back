Rails.application.routes.draw do
  resources :companies, only: [:show]
  resources :users do
    resources :companies, only: [:create, :update, :destroy]
  end

  resources :authentication, path: "auth", only: [] do
    collection do
      post :login
      post :forgot_password
      post :logout
    end
  end
end
