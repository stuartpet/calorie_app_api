# app/serializers/food_item_serializer.rb
class FoodItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :calories, :protein, :carbs, :fat, :sugar, :salt, :supabase_url, :user_generated, :source
end
