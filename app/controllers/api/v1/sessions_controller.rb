module Api
  module V1
    class SessionsController < ApplicationController
      before_action :authenticate_user!, only: [:show]

      def create
        email = params[:email].to_s.downcase.strip

        if email.blank?
          return render json: { error: 'Email required' }, status: :unprocessable_entity
        end

        user = User.find_or_create_by(email: email)
        user.update(auth_token: SecureRandom.hex(16))

        render json: { token: user.auth_token }
      end

      def show
        render json: { email: @current_user.email }
      end
    end
  end
end
