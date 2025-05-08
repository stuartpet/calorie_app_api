class FoodItem < ApplicationRecord
  has_many :meals
  has_one_attached :image # ✅ This line adds image support

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
