# lib/tasks/supabase.rake
namespace :supabase do
  desc "Re-upload and rename local images to Supabase with normalized names"
  task resync_images: :environment do
    uploader = SupabaseUploader
    count = 0

    FoodItem.includes(image_attachment: :blob).find_each do |item|
      next unless item.image.attached?

      slug = item.name.parameterize
      filename = "#{item.id}/#{slug}.jpg"

      if uploader.exists?(filename)
        puts "⏭️ Skipping #{filename} (already exists)"
        next
      end

      puts "⬆️ Uploading: #{filename} for #{item.name}"

      io = StringIO.new(item.image.download)

      tries = 3
      begin
        result_url = uploader.upload(io, filename)

        if result_url
          puts "✔️ Uploaded to Supabase: #{result_url}"
          count += 1
        else
          puts "❌ Failed upload for #{item.name}"
        end
      rescue Faraday::TimeoutError => e
        tries -= 1
        puts "⚠️ Timeout uploading #{filename}. Retries left: #{tries}"
        retry if tries > 0
        puts "❌ Giving up on #{filename}"
      end
    end

    puts "\n✅ Completed upload of #{count} images."
  end
end
