# frozen_string_literal: true

# middleware for retrying bad-nonce errors, which are safe to retry per spec
# the error response will also include a fresh nonce to use so no extra request is made
# see https://ietf-wg-acme.github.io/acme/draft-ietf-acme-acme.html#replay-protection
class Acme::Client::NonceRetryMiddleware < Faraday::Middleware
  def initialize(app)
    super

    @app = app
  end

  def call(env)
    # duplicate so we can retry request using original `env` obj
    @app.call(env.dup)
  rescue Acme::Client::Error::BadNonce
    retry
  end
end
