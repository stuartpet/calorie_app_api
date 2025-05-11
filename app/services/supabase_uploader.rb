# app/services/supabase_uploader.rb
class SupabaseUploader
  SUPABASE_URL = Rails.application.credentials.supabase[:url]
  SUPABASE_KEY = Rails.application.credentials.supabase[:service_role_key]
  BUCKET = 'foodimages'

  def self.upload(io, filename)
    conn = Faraday.new(
      url: "#{SUPABASE_URL}/storage/v1/object",
      headers: {
        'Authorization' => "Bearer #{SUPABASE_KEY}",
        'Content-Type' => 'application/octet-stream'
      }
    )

    path = "#{BUCKET}/#{SecureRandom.hex}/#{filename}"

    response = conn.put(path) { |req| req.body = io.read }

    if response.success?
      "#{SUPABASE_URL}/storage/v1/object/public/#{path}"
    else
      Rails.logger.error("❌ Supabase upload failed: #{response.status} - #{response.body}")
      nil
    end
  end
end
