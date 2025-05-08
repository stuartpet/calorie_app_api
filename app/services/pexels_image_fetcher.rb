# app/services/pexels_image_fetcher.rb
require 'json'
require 'faraday'

class PexelsImageFetcher
  BASE_URL = "https://api.pexels.com/v1/search"
  API_KEY = Rails.application.credentials.pexels[:api_key]
  CACHE_PATH = Rails.root.join("tmp", "pexels_cache.json")

  def self.fetch_image_url(query)
    normalized_query = query.strip.downcase
    cache = load_cache

    if cache[normalized_query]
      puts "⚡ Using cached image for '#{normalized_query}'"
      return cache[normalized_query]
    end

    response = Faraday.get(BASE_URL, { query: normalized_query, per_page: 1 }, { Authorization: API_KEY })

    if response.status == 429
      sleep_time = rand(10..20)
      puts "⏳ Rate limited. Sleeping for #{sleep_time}s..."
      sleep sleep_time
      return nil
    end

    json = JSON.parse(response.body)
    image_url = json["photos"]&.first&.dig("src", "medium")

    if image_url
      cache[normalized_query] = image_url
      save_cache(cache)
    end

    image_url
  rescue => e
    puts "⚠️ Pexels error for #{query}: #{e.message}"
    nil
  end

  def self.load_cache
    File.exist?(CACHE_PATH) ? JSON.parse(File.read(CACHE_PATH)) : {}
  end

  def self.save_cache(data)
    FileUtils.mkdir_p(CACHE_PATH.dirname)
    File.write(CACHE_PATH, JSON.pretty_generate(data))
  end
end
