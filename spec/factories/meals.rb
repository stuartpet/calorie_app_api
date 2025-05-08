FactoryBot.define do
  factory :meal do
    user
    food_item
    name { "Test Meal" }
    calories { 500 }
    eaten_at { Time.zone.now }
  end
end

