#!/usr/bin/env ruby
# db/scripts/attach_food101_images.rb
require 'open-uri'

FOOD101_DIR = Rails.root.join("db", "data", "food101", "food-101", "images")
puts "🔍 Looking in #{FOOD101_DIR}"

unless Dir.exist?(FOOD101_DIR)
  puts "❌ Directory not found: #{FOOD101_DIR}"
  exit
end

attached = 0
unmatched = []

def normalize_for_folder(str)
  str.downcase.gsub(/[^a-z0-9\s]/, '').strip.gsub(/\s+/, '_')
end

folder_names = Dir.children(FOOD101_DIR).select { |f| File.directory?(FOOD101_DIR.join(f)) }

folder_names.each do |folder|
  image_file = Dir[FOOD101_DIR.join(folder, "*.jpg")].first
  next unless image_file && File.exist?(image_file)

  match = FoodItem.find do |item|
    normalize_for_folder(item.name) == folder
  end

  if match
    unless match.image.attached?
      match.image.attach(io: File.open(image_file), filename: "#{folder}.jpg")
      attached += 1
      puts "📷 Attached image for #{match.name}"
    end
  else
    unmatched << folder
  end
end

puts "✅ Done. Images attached: #{attached}"
puts "⚠️ Unmatched folders: #{unmatched.count}"
puts unmatched.join(", ") unless unmatched.empty?
