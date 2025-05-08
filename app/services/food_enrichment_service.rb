class FoodEnrichmentService
  def self.enrich!(name)
    prompt = <<~PROMPT
      Estimate the average calories, protein (g), carbs (g), fat (g), sugar (g), and salt (mg) for a typical serving of "#{name}". 
      Respond with a JSON object like:
      {
        "calories": 400,
        "protein": 25,
        "carbs": 35,
        "fat": 15,
        "sugar": 5,
        "salt": 600
      }
    PROMPT

    response = OpenAIClient.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.2
      }
    )

    content = response.dig("choices", 0, "message", "content")

    if content.nil?
      puts "[FoodEnrichmentService] GPT returned nil content for '#{name}'"
      puts response.inspect
      return
    end

    json = JSON.parse(content)

    FoodItem.create!(
      name: name,
      calories: json["calories"],
      protein: json["protein"],
      carbs: json["carbs"],
      fat: json["fat"],
      sugar: json["sugar"],
      salt: json["salt"],
      source: "gpt-3.5-turbo"
    )
  rescue JSON::ParserError => e
    puts "[FoodEnrichmentService] Failed to parse response for #{name}: #{e.message}"
    puts content
    nil
  end
end
