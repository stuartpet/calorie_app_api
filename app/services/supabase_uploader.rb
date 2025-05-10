require 'faraday'

class SupabaseUploader
  def self.upload(file_path, filename)
    url = "#{ENV['SUPABASE_PROJECT_URL']}/storage/v1/object/#{ENV['SUPABASE_BUCKET']}/#{filename}"

    response = Faraday.put(url) do |req|
      req.headers['Authorization'] = "Bearer #{ENV['SUPABASE_SERVICE_KEY']}"
      req.headers['Content-Type'] = 'application/octet-stream'
      req.body = File.read(file_path)
    end

    if response.success?
      "#{ENV['SUPABASE_PROJECT_URL']}/storage/v1/object/public/#{ENV['SUPABASE_BUCKET']}/#{filename}"
    else
      Rails.logger.error "Supabase upload failed: #{response.status} - #{response.body}"
      nil
    end
  end
end
