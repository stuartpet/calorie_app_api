class CreateFoodItems < ActiveRecord::Migration[7.2]
  def change
    create_table :food_items do |t|
      t.string :name
      t.integer :calories
      t.integer :protein
      t.integer :carbs
      t.integer :fat
      t.integer :sugar
      t.integer :salt
      t.string :source

      t.timestamps
    end
  end
end
