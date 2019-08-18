Rails.application.routes.draw do
  resources :tracks, only: [:search] do
    collection do
      get :search
      get :features
      get :lyrics
    end
  end
  resources :wakes, only: [:index]
end
