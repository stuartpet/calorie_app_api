# app/services/food_seeder_service.rb
require 'csv'

class FoodSeederService
  def self.seed_from_csv(file_path)
    puts "🌱 Seeding food items from CoFID CSV..."

    CSV.foreach(file_path, headers: true) do |row|
      name = row['Food Name']
      next if name.blank?

      item = FoodItem.find_or_initialize_by(name: name)

      item.assign_attributes(
        calories: row['Energy (kcal) (kcal)'],
        protein: row['Protein (g)'],
        fat: row['Fat (g)'],
        carbs: row['Carbohydrate (g)'],
        sugar: row['Total sugars (g)'],
        salt: row['Salt (g)'],
        user_generated: false
      )

      item.save!
    end

    puts "✅ Seeding complete."
  end
end
