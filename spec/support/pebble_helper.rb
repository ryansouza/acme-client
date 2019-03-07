module PebbleHelper
  def run_challenge(challenge, **args)
    setup_challenge(challenge, **args)

    yield

    retry_until condition: -> { challenge.status != 'pending' }, retry_count: 10 do
      challenge.reload
    end
  end

  def setup_challenge(challenge, domain: nil)
    case challenge
    when Acme::Client::Resources::Challenges::DNS01
      raise ArgumentError, 'DNS challenges require :domain' unless domain

      host = "#{challenge.record_name}.#{domain}."

      pebble_client.post 'clear-txt', { host: host }.to_json
      pebble_client.post 'set-txt', { host: host, value: challenge.record_content }.to_json
    when Acme::Client::Resources::Challenges::HTTP01
      pebble_client.post 'add-http01', { token: challenge.token, content: challenge.file_content }.to_json
    else
      raise ArgumentError, "Unsupported challenge: #{challenge.class}"
    end
  end

  private

  def pebble_client
    @pebble_client ||= Faraday.new('http://localhost:8055/') do |conn|
      conn.response :raise_error
      conn.adapter Faraday.default_adapter
    end
  end
end
