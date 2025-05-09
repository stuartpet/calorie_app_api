# scripts/link_local_images_to_food_items.rb
require_relative '../../config/environment'

LOCAL_IMAGE_DIR = Rails.root.join('db', 'data', 'food_images')
attached = 0
skipped = 0

Dir.glob("#{LOCAL_IMAGE_DIR}/**/*.jpg").each do |image_path|
  filename = File.basename(image_path, '.jpg')
  name_guess = filename.gsub(/[-_]/, ' ').gsub(/\d+$/, '').strip.titleize

  match = FoodItem.where('LOWER(name) LIKE ?', "%#{name_guess.downcase}%").first

  if match && !match.image.attached?
    match.image.attach(io: File.open(image_path), filename: "#{match.name.parameterize}.jpg")
    puts "📎 Attached local image to: #{match.name}"
    attached += 1
  else
    puts "⏭️ Skipped: #{name_guess} (#{match ? 'already attached' : 'no match'})"
    skipped += 1
  end
end

puts "\n✅ Done. Attached: #{attached}, Skipped: #{skipped}"
