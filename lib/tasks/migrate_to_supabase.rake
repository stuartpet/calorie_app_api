namespace :supabase do
  desc "Migrate FoodItem ActiveStorage images to Supabase"
  task migrate_images: :environment do
    require 'faraday'
    require 'open-uri'

    puts "🚀 Starting Supabase image migration..."

    count = 0

    FoodItem.includes(image_attachment: :blob).find_each do |item|
      next unless item.image.attached?
      next if item.supabase_image_url.present?

      item.image.blob.open do |io|
        filename = "#{item.name.parameterize}#{File.extname(item.image.filename.to_s)}"
        url = SupabaseUploader.upload(io, filename)

        if url
          item.update!(supabase_image_url: url)
          puts "✅ Uploaded #{item.name}"
          count += 1
        else
          puts "❌ Failed to upload #{item.name}"
        end
      end
    end

    puts "🎉 Migration complete. Uploaded #{count} images."
  end
end
