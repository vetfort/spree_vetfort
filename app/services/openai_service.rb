require 'httparty'

class OpenaiService
  include HTTParty
  base_uri 'https://api.openai.com/v1'

  def complete(prompt)
    response = self.class.post(
      '/chat/completions',
      headers: headers,
      body: {
        model: "gpt-4o-2024-08-06",
        messages: [
          { role: "system", content: "You are a helpful assistant that writes product descriptions and translations." },
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }.to_json
    )

    JSON.parse(response.body)
  end

  private

  def headers
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}"
    }
  end
end
