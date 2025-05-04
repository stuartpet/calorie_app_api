module Api
  module V1
    class SessionsController < ApplicationController
      before_action :authenticate_user!, only: [:show]

      def create
        email = params[:email].to_s.downcase.strip

        if email.blank?
          return render json: { error: 'Email required' }, status: :unprocessable_content
        end

        user = User.find_or_create_by(email: email)
        user.update(auth_token: SecureRandom.hex(16))

        render json: { token: user.auth_token }
      end

      def show
        render json: { email: @current_user.email }
      end

      def destroy
        token = request.headers['Authorization']
        user = User.find_by(auth_token: token)

        if user
          user.update(auth_token: nil)
          render json: { message: 'Logged out' }, status: :ok
        else
          render json: { error: 'Invalid token' }, status: :unauthorized
        end
      end
    end
  end
end
