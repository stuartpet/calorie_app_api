class FoodItem < ApplicationRecord
  has_many :meals
  has_one_attached :image # ✅ This line adds image support

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  def supabase_url
    base_url = Rails.application.credentials.supabase[:url]
    "#{base_url}/storage/v1/object/public/foodimages/#{id}/#{name.parameterize}.jpg"
  end
end
