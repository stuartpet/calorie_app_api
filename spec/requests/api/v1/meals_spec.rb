require 'rails_helper'

RSpec.describe 'Meals API', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => user.auth_token } }

  describe 'POST /api/v1/meals' do
    it 'creates a meal' do
      post '/api/v1/meals', params: {
        meal: { name: 'Pasta', calories: 500 }
      }, headers: headers

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['name']).to eq('Pasta')
    end
  end

  describe 'GET /api/v1/meals/today' do
    it 'returns today’s meals' do
      create(:meal, user: user, name: 'Oats', calories: 300, eaten_at: Time.zone.now)
      get '/api/v1/meals/today', headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end
end
