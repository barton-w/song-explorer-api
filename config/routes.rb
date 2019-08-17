Rails.application.routes.draw do
  resources :tracks, only: [:search] do
    collection do
      get :search
      get :features
    end
  end
end
