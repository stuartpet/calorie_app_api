class ApplicationController < ActionController::API
  private

  def authenticate_user!
    token = request.headers['Authorization']
    @current_user = User.find_by(auth_token: token)
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end
end
