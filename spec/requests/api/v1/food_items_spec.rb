# spec/requests/api/v1/food_items_spec.rb
require 'rails_helper'

RSpec.describe "API::V1::FoodItems", type: :request do
  let(:food_item) { FoodItem.create(name: "Tuna Sandwich", calories: 450, protein: 30, user_generated: false) }
  let(:meal) do
    create(:meal, user: user, food_item: food_item, name: 'Oats', calories: 300, eaten_at: Time.zone.now)
    end
  let(:user) { create(:user, email: "me@example.com", password: "password", auth_token: "testtoken123") }
  let(:auth_headers) { { "Authorization" => user.auth_token } }

  before do
    user
    meal
  end

  describe "GET /api/v1/food_items" do
    it "returns all food items" do
      get "/api/v1/food_items",  headers: auth_headers.merge({ "ACCEPT" => "application/json" })
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end

    it "returns exact match with name param" do
      get "/api/v1/food_items", headers: auth_headers.merge({ "ACCEPT" => "application/json" }), params: { name: "Tuna Sandwich" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["name"]).to eq("Tuna Sandwich")
    end

    it "returns partial matches with query param" do
      get "/api/v1/food_items",  headers: auth_headers.merge({ "ACCEPT" => "application/json" }), params: { query: "sand" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first["name"]).to eq("Tuna Sandwich")
    end

    it "returns not found and suggestion if name not found" do
      get "/api/v1/food_items",  headers: auth_headers.merge({ "ACCEPT" => "application/json" }), params: { name: "Lasagna" }
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to include("No match for")
      expect(body["suggestion"]).to include("Would you like to add")
    end
  end
end
