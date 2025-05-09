#!/usr/bin/env ruby
require_relative '../../config/environment'
require 'fileutils'

ROOT_DIR = Rails.root.join('db', 'data', 'food101', 'food-101', 'images')
IMAGE_EXT = %w[.jpg .jpeg .png]

attached = 0
skipped = 0

Dir.glob("#{ROOT_DIR}/**/*").each do |file_path|
  next unless IMAGE_EXT.include?(File.extname(file_path).downcase)

  folder = File.basename(File.dirname(file_path))
  base_name = File.basename(file_path, '.*')

  # Normalize name: e.g. "apple_pie" => "Apple Pie"
  food_name = folder.tr('_', ' ').split.map(&:capitalize).join(' ')

  # Find or create FoodItem
  item = FoodItem.find_or_create_by!(name: food_name)

  if item.image.attached?
    puts "🔸 Already has image: #{item.name}"
    skipped += 1
    next
  end

  begin
    item.image.attach(
      io: File.open(file_path),
      filename: "#{item.name.parameterize}.jpg",
      content_type: 'image/jpeg'
    )
    puts "📸 Attached image to #{item.name}"
    attached += 1
  rescue => e
    puts "❌ Failed to attach for #{item.name}: #{e.message}"
  end
end

puts "\n✅ Done! Attached: #{attached}, Skipped: #{skipped}"
