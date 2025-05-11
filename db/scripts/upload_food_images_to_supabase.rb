# script/upload_food_images_to_supabase.rb
require_relative '../config/environment'
require_relative '../app/services/supabase_uploader.rb'

IMAGE_DIR = Rails.root.join('db', 'data', 'food_images')

uploaded = 0
skipped = 0

Dir.glob("#{IMAGE_DIR}/*.{jpg,jpeg,png}").each do |file_path|
  filename = File.basename(file_path)
  food_name = File.basename(filename, '.*').tr('_', ' ').titleize.strip

  food_item = FoodItem.find_by('LOWER(name) = ?', food_name.downcase)

  if food_item
    next if food_item.image_url.present?

    File.open(file_path, 'rb') do |file|
      puts "🔼 Uploading image for: #{food_item.name}..."
      image_url = SupabaseUploader.upload(file, filename)

      if image_url
        food_item.update(image_url: image_url)
        puts "✅ Uploaded: #{food_item.name} -> #{image_url}"
        uploaded += 1
      else
        puts "❌ Failed to upload: #{filename}"
      end
    end
  else
    puts "⚠️ No FoodItem match found for: #{food_name} (from #{filename})"
    skipped += 1
  end
end

puts "🎉 Finished. Uploaded: #{uploaded}, Skipped (no match): #{skipped}"
