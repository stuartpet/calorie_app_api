require 'open-uri'

class OpenFoodFactsService
  MIN_CONFIDENCE = 0.75

  def self.find_by_barcode(barcode)
    response = Faraday.get("https://world.openfoodfacts.org/api/v0/product/#{barcode}.json")
    data = JSON.parse(response.body)
    return nil unless data['status'] == 1

    product = data['product']
    build_food_item(product, barcode: barcode)
  end

  def self.find_by_name(name)
    response = Faraday.get("https://world.openfoodfacts.org/cgi/search.pl", {
      search_terms: name,
      search_simple: 1,
      action: 'process',
      json: 1
    })

    data = JSON.parse(response.body)
    product = data['products']&.first
    return nil unless product

    build_food_item(product)
  end

  def self.build_food_item(product, barcode: nil)
    nutriments = product['nutriments'] || {}

    name        = product['product_name']
    image_url   = product['image_front_url']
    calories    = sanitize(nutriments['energy-kcal'])
    protein     = sanitize(nutriments['proteins'])
    carbs       = sanitize(nutriments['carbohydrates'])
    fat         = sanitize(nutriments['fat'])
    sugar       = sanitize(nutriments['sugars'])
    salt        = sanitize(nutriments['salt'])

    confidence = confidence_score(name, image_url, calories)

    return nil if confidence < MIN_CONFIDENCE

    item = FoodItem.new(
      name: name || 'Unnamed Product',
      description: product['generic_name'] || 'Scanned via OpenFoodFacts',
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      sugar: sugar,
      salt: salt,
      barcode: barcode,
      source: 'open_food_facts',
      user_generated: false
    )

    if item.save && image_url.present?
      begin
        io = StringIO.new(URI.open(image_url).read)
        filename = "#{item.id}/#{item.name.parameterize}.jpg"
        SupabaseUploader.upload(io, filename)
      rescue => e
        Rails.logger.warn("OpenFoodFacts image upload failed: #{e.message}")
      end
    end

    item.define_singleton_method(:confidence_score) { confidence }
    item.persisted? ? item : nil
  end

  def self.sanitize(value)
    return 0 unless value.present?
    value.to_f
  end

  def self.confidence_score(name, image_url, calories)
    score = 0.0
    score += 0.4 if name.present?
    score += 0.3 if image_url.present?
    score += 0.3 if calories.to_f > 0
    score
  end
end
