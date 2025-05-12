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

    if item && similarity(normalized, item.name.downcase) < 0.2
      return render json: {
        confident: true,
        confidence_score: 1.0,
        match: FoodItemSerializer.new(item).as_json
      }
    end

    # Fallback via OpenFoodFacts based on the normalized name
    fallback_item = OpenFoodFactsService.find_by_name(normalized)
    if fallback_item
      return render json: {
        confident: true,
        confidence_score: fallback_item.confidence_score,
        match: FoodItemSerializer.new(fallback_item).as_json
      }, status: :created
    end

    # If no match is sufficiently confident, return fuzzy suggestions
    suggestions = matcher.find_all(normalized, limit: 3)
    render json: { confident: false, suggestions: suggestions }
  end

  private

  def normalize(name)
    name.gsub(/[^a-z0-9\s]/i, '').strip.downcase
  end

  def similarity(a, b)
    Levenshtein.distance(a, b).to_f / [a.size, b.size].max
  end
end
