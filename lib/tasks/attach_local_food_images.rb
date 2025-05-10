# lib/tasks/attach_local_food_images.rb
require_relative '../../config/environment'

IMAGES_PATH = Rails.root.join("db/data/food_images")
attached = 0
skipped = 0

Dir.glob("#{IMAGES_PATH}/**/*.jpg").each do |image_path|
  filename = File.basename(image_path, ".jpg").tr("_", " ").downcase
  match = FoodItem.find_by("LOWER(name) = ?", filename)

  if match
    unless match.image.attached?
      match.image.attach(io: File.open(image_path), filename: "#{match.name.parameterize}.jpg")
      puts "📸 Attached image to '#{match.name}'"
      attached += 1
    else
      skipped += 1
    end
  else
    puts "❌ No match for '#{filename}'"
  end
end

puts "✅ Done! Attached: #{attached}, Skipped (already attached): #{skipped}"
