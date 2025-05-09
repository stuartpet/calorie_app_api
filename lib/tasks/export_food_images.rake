# lib/tasks/export_food_images.rake

require 'fileutils'

namespace :food_images do
  desc "Export attached FoodItem images to db/data/food_images/"
  task export: :environment do
    output_dir = Rails.root.join('db', 'data', 'food_images')
    FileUtils.mkdir_p(output_dir)

    count = 0

    FoodItem.includes(image_attachment: :blob).find_each do |item|
      next unless item.image.attached?

      begin
        filename = "#{item.name.parameterize}.jpg"
        path = output_dir.join(filename)

        # Download and save the image
        File.open(path, 'wb') do |file|
          file.write(item.image.download)
        end

        puts "✅ Saved: #{filename}"
        count += 1
      rescue => e
        puts "❌ Failed to save image for #{item.name}: #{e.message}"
      end
    end

    puts "\n🎉 Done! Exported #{count} food images to #{output_dir}"
  end
end
