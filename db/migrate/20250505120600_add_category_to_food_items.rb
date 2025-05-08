class AddCategoryToFoodItems < ActiveRecord::Migration[7.2]
  def change
    add_column :food_items, :category, :string
  end
end
