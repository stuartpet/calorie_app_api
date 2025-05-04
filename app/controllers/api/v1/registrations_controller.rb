module Api
  module V1
    class RegistrationsController < ApplicationController
      def create
        user = User.new(user_params)
        user.auth_token = SecureRandom.hex(20)

        if user.save
          render json: { message: 'User created successfully' }, status: :created
        else
          render json: { error: user.errors.full_messages.join(', ') }, status: :unprocessable_content
        end
      end

      private

      def user_params
        params.permit(:email, :password)
      end
    end
  end
end
