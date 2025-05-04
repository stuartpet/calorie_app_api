require 'rails_helper'

RSpec.describe 'Calorie Calculator', type: :request do
  describe 'POST /api/v1/calories/calculate' do
    it 'returns calculated calories for valid input' do
      post '/api/v1/calories/calculate', params: {
        age: 30,
        gender: 'male',
        weight: 72,
        height: 183,
        activity_level: 'moderate',
        goal: 'gain'
      }

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json['bmr']).to be > 1400
      expect(json['maintenance_calories']).to be > 2000
      expect(json['daily_calorie_target']).to be > 2200
    end

    it 'returns error for missing params' do
      post '/api/v1/calories/calculate', params: { age: 30 }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['error']).to match(/Missing params/)
    end
  end
end
