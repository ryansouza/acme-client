# frozen_string_literal: true

class Acme::Client::Resources::Challenges::TLSALPN01 < Acme::Client::Resources::Challenges::Base
  CHALLENGE_TYPE = 'tls-alpn-01'.freeze
end
