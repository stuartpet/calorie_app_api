Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Food Items
      resources :food_items, only: [:index, :show, :create, :update] do
        collection do
          post :create_custom
          get :barcode_lookup
        end
      end

      # Meals
      resources :meals, only: [:create, :update, :destroy], param: :id do
        collection do
          get :today
        end
      end

      # Calorie Calculation
      get  "calorie_calculator/calculate", to: "calorie_calculator#calculate"
      post "calories/calculate",          to: "calorie_calculator#calculate"

      # Photo Analysis
      post "photo_meals/analyze", to: "photo_meals#analyze"

      # Auth
      post   "login",  to: "sessions#create"
      post   "signup", to: "registrations#create"
      delete "logout", to: "sessions#destroy"
      get    "me",     to: "sessions#show"
      put    "me",     to: "users#update"
    end
  end
end
