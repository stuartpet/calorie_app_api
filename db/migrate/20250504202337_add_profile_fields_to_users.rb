class AddProfileFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :age, :integer
    add_column :users, :height, :integer
    add_column :users, :weight, :integer
    add_column :users, :gender, :string
    add_column :users, :activity_level, :string
    add_column :users, :goal, :string
  end
end
