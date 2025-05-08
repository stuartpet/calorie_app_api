class Api::V1::PhotoMealsController < ApplicationController
  before_action :authenticate_user!

  def analyze
    if params[:image].blank?
      return render json: { error: 'Image is required' }, status: :bad_request
    end

    uploaded_file = params[:image]
    filename = File.basename(uploaded_file.original_filename, ".*")

    normalized = normalize(filename)

    food_items = FoodItem.all
    matcher = FuzzyMatch.new(food_items.map(&:name), read: :downcase)
    best_match = matcher.find(normalized)

    confidence = best_match && similarity(normalized, best_match) > 0.85

    if confidence
      item = FoodItem.find_by(name: best_match)
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
      render json: {
        confident: false,
        suggestions: suggestions
      }
    end
  end

  private

  def normalize(name)
    name.downcase.gsub(/[^a-z0-9\s]/i, '').strip
  end

  def similarity(a, b)
    Levenshtein.distance(a, b).to_f / [a.size, b.size].max
  end
end
