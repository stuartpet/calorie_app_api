class AddSupabaseImageUrlToFoodItems < ActiveRecord::Migration[7.2]
  def change
    add_column :food_items, :supabase_image_url, :string
  end
end
