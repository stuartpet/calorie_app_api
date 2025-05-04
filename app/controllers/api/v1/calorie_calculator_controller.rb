module Api
  module V1
    class CalorieCalculatorController < ApplicationController

      def calculate
        required_params = %i[age gender height weight activity_level goal]
        missing = required_params.select { |p| params[p].blank? }

        return render json: { error: "Missing params: #{missing.join(', ')}" }, status: :bad_request if missing.any?

        bmr = calculate_bmr(params[:gender], params[:weight].to_f, params[:height].to_f, params[:age].to_i)
        maintenance = bmr * activity_multiplier(params[:activity_level])
        target = adjust_for_goal(maintenance, params[:goal])

        render json: {
          bmr: bmr.round,
          maintenance_calories: maintenance.round,
          daily_calorie_target: target.round
        }
      end

      private

      def calculate_bmr(gender, weight, height, age)
        base = 10 * weight + 6.25 * height - 5 * age
        gender.downcase == "male" ? base + 5 : base - 161
      end

      def activity_multiplier(level)
        {
          "sedentary" => 1.2,
          "light"     => 1.375,
          "moderate"  => 1.55,
          "active"    => 1.725
        }[level.downcase] || 1.2
      end

      def adjust_for_goal(calories, goal)
        case goal.downcase
        when "lose" then calories * 0.8
        when "gain" then calories * 1.15
        else calories
        end
      end
    end
  end
end
