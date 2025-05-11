# app/services/local_image_attacher.rb
require 'fuzzy_match'

class LocalImageAttacher
  IMAGE_DIR = Rails.root.join("db/data/food_images")

  def self.run!
    matcher = FuzzyMatch.new(FoodItem.pluck(:name))

    Dir.glob("#{IMAGE_DIR}/**/*.jpg").each do |path|
      filename = File.basename(path, ".jpg").tr("_-", " ").downcase
      match_name = matcher.find(filename)

      next unless match_name

      item = FoodItem.find_by(name: match_name)
      next if item.nil? || item.image.attached?

      item.image.attach(
        io: File.open(path),
        filename: "#{item.name.parameterize}.jpg"
      )

      puts "✅ Linked #{File.basename(path)} to #{item.name}"
    rescue => e
      puts "❌ Failed for #{path}: #{e.message}"
    end
  end
end
