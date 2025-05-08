require 'image_processing/mini_magick'
require 'digest'

class ImageMatcherService
  def self.analyze(uploaded_image)
    resized = ImageProcessing::MiniMagick
                .source(uploaded_image)
                .resize_to_limit(128, 128)
                .convert("jpg")
                .call

    digest = Digest::SHA2.hexdigest(File.read(resized.path))

    matches = []

    FoodItem.with_attached_image.find_each do |item|
      next unless item.image.attached?

      local_path = ActiveStorage::Blob.service.path_for(item.image.key)
      next unless File.exist?(local_path)

      begin
        item_digest = Digest::SHA2.hexdigest(File.read(local_path))
        similarity = levenshtein_score(digest, item_digest)
        matches << { item: item, score: similarity }
      rescue => e
        Rails.logger.warn("Digest error for #{item.name}: #{e}")
      end
    end

    top = matches.sort_by { |m| m[:score] }.first(3)
    top
  end

  def self.levenshtein_score(a, b)
    Levenshtein.distance(a, b)
  end
end
