Rails.application.routes.draw do
  resources :users

  resources :authentication, path: "auth", only: [] do
    collection do
      post :login
      post :forgot_password
      post :logout
    end
  end
end
