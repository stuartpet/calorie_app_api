module AuthHelpers
  def auth_headers_for(user)
    { 'Authorization' => user.auth_token }
  end

  def sign_in_as(user)
    user.update(auth_token: SecureRandom.hex(20)) unless user.auth_token
    auth_headers_for(user)
  end
end
