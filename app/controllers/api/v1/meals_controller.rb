module Api
  module V1
    class MealsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_meal, only: [:update, :destroy]

      def create
        name = meal_params[:name].strip.titleize
        calories = meal_params[:calories].to_i

        food_item = FoodItem.find_or_create_by!(name: name) do |item|
          item.calories = calories
          item.user_generated = true
        end

        meal = @current_user.meals.create!(
          food_item: food_item,
          name: food_item.name,
          calories: calories,
          eaten_at: Time.zone.now
        )

        render json: meal, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record&.errors&.full_messages }, status: :unprocessable_content
      end

      def update
        meal = @current_user.meals.find_by(id: params[:id])
        return render json: { error: 'Meal not found' }, status: :not_found unless meal

        if meal.update(meal_params)
          render json: meal
        else
          render json: { error: meal.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        meal = @current_user.meals.find_by(id: params[:id])
        return render json: { error: 'Meal not found' }, status: :not_found unless meal

        meal.destroy
        render json: { message: 'Meal deleted' }, status: :ok
      end

      def today
        meals = @current_user.meals.where(eaten_at: Time.zone.today.all_day).order(:eaten_at)
        render json: meals
      end

      private

      def meal_params
        params.require(:meal).permit(:name, :calories)
      end

      def set_meal
        @meal = @current_user.meals.find_by(id: params[:id])
        render json: { error: 'Meal not found' }, status: :not_found unless @meal
      end
    end
  end
end
