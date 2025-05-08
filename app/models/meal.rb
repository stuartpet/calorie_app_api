class Meal < ApplicationRecord
  belongs_to :user
  belongs_to :food_item, optional: true
  has_one_attached :image

  validates :name, presence: true
  validates :calories, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :eaten_at, presence: true
end