module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_user!

      def show
        render json: {
          email: @current_user.email,
          age: @current_user.age,
          height: @current_user.height,
          weight: @current_user.weight,
          gender: @current_user.gender,
          activity_level: @current_user.activity_level,
          goal: @current_user.goal
        }
      end

      def update
        if @current_user.update(user_params)
          render json: { message: 'Profile updated' }
        else
          render json: { error: @current_user.errors.full_messages.join(', ') }, status: :unprocessable_content
        end
      end

      private

      def user_params
        params.permit(:age, :height, :weight, :gender, :activity_level, :goal)
      end
    end
  end
end
