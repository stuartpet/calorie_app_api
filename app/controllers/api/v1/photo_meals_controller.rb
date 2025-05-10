# app/controllers/api/v1/photo_meals_controller.rb
class Api::V1::PhotoMealsController < ApplicationController
  before_action :authenticate_user!

  def analyze
    return render json: { error: 'Image is required' }, status: :bad_request if params[:image].blank?

    uploaded_file = params[:image]
    filename = File.basename(uploaded_file.original_filename, ".*").tr("_", " ").downcase
    normalized = normalize(filename)

    matcher = FuzzyMatch.new(FoodItem.pluck(:name), read: :downcase)
    best_match = matcher.find(normalized)
    item = FoodItem.find_by("LOWER(name) = ?", best_match.downcase) if best_match

    if item && item.image.attached? && similarity(normalized, item.name.downcase) < 0.2
      render json: {
        confident: true,
        match: {
          id: item.id,
          name: item.name,
          calories: item.calories
        }
      }
    else
      suggestions = matcher.find_all(normalized, limit: 3)
      render json: { confident: false, suggestions: suggestions }
    end
  end

  private

  def normalize(name)
    name.gsub(/[^a-z0-9\s]/i, '').strip.downcase
  end

  def similarity(a, b)
    Levenshtein.distance(a, b).to_f / [a.size, b.size].max
  end
end
