module Api
  module V1
    class FoodItemsController < ApplicationController
      before_action :authenticate_user!, except: [:index, :show]

      def index
        if params[:name].present?
          item = FoodItem.find_by('LOWER(name) = ?', params[:name].downcase)
          return render json: item if item

          render json: {
            error: "No match for '#{params[:name]}'",
            suggestion: "Would you like to add this as a new food item?"
          }, status: :not_found
        elsif params[:query].present?
          matches = FoodItem.where('LOWER(name) LIKE ?', "%#{params[:query].downcase}%")
          render json: matches
        else
          render json: FoodItem.all
        end
      end


      def show
        item = FoodItem.find_by(id: params[:id])
        if item
          render json: item
        else
          render json: { error: 'Food item not found' }, status: :not_found
        end
      end

      def create
        item = FoodItem.find_by(id: params[:food_item_id])
        return render json: { error: "Food item not found" }, status: :not_found unless item

        meal = @current_user.meals.create!(
          food_item: item,
          name: item.name,
          calories: item.calories,
          protein: item.protein,
          carbs: item.carbs,
          fat: item.fat,
          sugar: item.sugar,
          salt: item.salt
        )

        render json: meal, status: :created
      end


      def update
        item = FoodItem.find(params[:id])
        if item.update(food_item_params)
          render json: item
        else
          render json: { error: item.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def food_item_params
        params.require(:food_item).permit(:name, :description, :calories, :protein, :carbs, :fat, :sugar, :salt, :image)
      end
    end
  end
end