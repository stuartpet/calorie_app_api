# app/services/supabase_uploader.rb
class SupabaseUploader
  SUPABASE_URL = Rails.application.credentials.supabase[:url]
  SUPABASE_KEY = Rails.application.credentials.supabase[:service_role_key]
  BUCKET = 'foodimages'

  def self.upload(io, filename)
    return if exists?(filename)

    conn = Faraday.new(
      url: "#{SUPABASE_URL}/storage/v1/object",
      headers: {
        'Authorization' => "Bearer #{SUPABASE_KEY}",
        'Content-Type' => 'application/octet-stream'
      }
    )

    path = "#{BUCKET}/#{filename}"
    res = conn.put(path) { |req| req.body = io.read }

    res.success? ? "#{SUPABASE_URL}/storage/v1/object/public/#{path}" : nil
  end

  def self.exists?(filename)
    conn = Faraday.new(
      url: "#{SUPABASE_URL}/storage/v1/object/public",
      headers: {
        'Authorization' => "Bearer #{SUPABASE_KEY}"
      }
    )

    path = "#{BUCKET}/#{filename}"
    res = conn.head(path)
    res.success?
  end
end
