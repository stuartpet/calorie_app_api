require 'net/http'
require 'uri'
require 'json'

class HuggingFaceFoodClassifier
  API_URL = "https://api-inference.huggingface.co/models/your-username/your-model-name"
  HEADERS = {
    "Authorization" => "Bearer #{Rails.application.credentials.huggingface[:api_key]}"
  }

  def self.predict(uploaded_file)
    image_data = uploaded_file.read

    uri = URI.parse(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, HEADERS)
    request.body = image_data

    response = http.request(request)
    result = JSON.parse(response.body)

    top = result.first
    if top && top["score"] > 0.85
      { confident: true, name: top["label"] }
    else
      suggestions = result.map { |r| r["label"] }
      { confident: false, suggestions: suggestions }
    end
  rescue => e
    Rails.logger.error("HuggingFace error: #{e.message}")
    { confident: false, suggestions: [] }
  end
end
