require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'POST /api/v1/login' do
    it 'returns an auth token for a valid email' do
      post '/api/v1/login', params: { email: 'test@example.com' }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['token']).to be_present
    end
  end

  describe 'GET /api/v1/me' do
    let(:user) { create(:user, email: 'me@example.com', auth_token: 'abc123') }

    before { user }
    
    it 'returns user email when token is valid' do
      get '/api/v1/me', headers: { 'Authorization' => 'abc123' }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['email']).to eq('me@example.com')
    end

    it 'returns error for invalid token' do
      get '/api/v1/me', headers: { 'Authorization' => 'wrongtoken' }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
