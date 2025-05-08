class AddRequiredFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    def change
      change_column_default :users, :age, 18
      change_column_default :users, :height, 170
      change_column_default :users, :weight, 70
      change_column_default :users, :gender, 'other'
      change_column_default :users, :activity_level, 'moderate'
      change_column_default :users, :goal, 'maintain'

      change_column_null :users, :age, false
      change_column_null :users, :height, false
      change_column_null :users, :weight, false
      change_column_null :users, :gender, false
      change_column_null :users, :activity_level, false
      change_column_null :users, :goal, false
    end

  end
end
