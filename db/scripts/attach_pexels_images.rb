#!/usr/bin/env ruby
require_relative '../../config/environment'
require_relative '../../app/services/pexels_image_fetcher'
require 'uri'
require 'open-uri'

LOG_FILE = Rails.root.join("log", "pexels_attempted_ids.txt")
attached = 0

attempted_ids = File.exist?(LOG_FILE) ? File.read(LOG_FILE).split.map(&:to_i) : []

FoodItem.where.not(id: attempted_ids).find_each do |item|
  next if item.image.attached?

  puts "🔍 Searching image for #{item.name}"
  image_url = PexelsImageFetcher.fetch_image_url(item.name)

  if image_url
    begin
      item.image.attach(io: URI.open(image_url), filename: "#{item.name.parameterize}.jpg")
      puts "📷 Attached image to #{item.name}"
      attached += 1
    rescue => e
      puts "❌ Failed to attach image for #{item.name}: #{e.message}"
    end
  else
    puts "⚠️ No image found for #{item.name}"
  end

  # Log the attempt regardless of success
  File.open(LOG_FILE, "a") { |f| f.puts(item.id) }

  # Sleep to avoid rate limit
  sleep(rand(1.5..3.0))
end

puts "✅ Finished attaching Pexels images (#{attached} total)"
