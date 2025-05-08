class AddFoodItemToMeals < ActiveRecord::Migration[7.2]
  def change
    add_reference :meals, :food_item, null: false, foreign_key: true
  end
end
