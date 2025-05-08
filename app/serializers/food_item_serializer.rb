# app/serializers/food_item_serializer.rb
class FoodItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :calories, :protein, :carbs, :fat, :sugar, :salt, :image_url, :user_generated, :source

  def image_url
    if object.image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.image, only_path: true)
    else
      nil
    end
  end
end
