Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :food_items, only: [:index, :show, :create, :update]

      resources :meals, only: [:create] do
        collection do
          get :today
        end
      end

      resources :meals, only: [:update, :destroy], param: :id

      get "calorie_calculator/calculate"
      post "photo_meal/analyze", to: "photo_meals#analyze"
      post 'photo_meals/analyze', to: 'photo_meals#analyze'
      post "login", to: "sessions#create"
      post 'signup', to: 'registrations#create'
      get "me", to: "sessions#show"
      put '/me', to: 'users#update'
      get '/me', to: 'users#show'
      delete 'logout', to: 'sessions#destroy'
      post "calories/calculate", to: "calorie_calculator#calculate"
    end
  end
end

