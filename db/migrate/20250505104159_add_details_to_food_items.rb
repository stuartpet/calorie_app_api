class AddDetailsToFoodItems < ActiveRecord::Migration[7.2]
  def change
    add_column :food_items, :description, :string
    add_column :food_items, :image_url, :string
    add_column :food_items, :user_generated, :boolean
  end
end
