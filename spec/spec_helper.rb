$LOAD_PATH.unshift File.join(__dir__, '../lib')
$LOAD_PATH.unshift File.join(__dir__, 'support')

require 'openssl'

DIRECTORY_URL = ENV['ACME_DIRECTORY_URL'] || 'https://localhost:14000/dir'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

require 'acme/client'

require 'rspec'
require 'pry'

require 'asn1_helper'
require 'retry_helper'
require 'ssl_helper'
require 'tls_helper'
require 'pebble_helper'
require 'profile_helper' if ENV['RUBY_PROF']

# pebble use self-signed certificate
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

RSpec.configure do |c|
  c.include Asn1Helper
  c.include TlsHelper
  c.include RetryHelper
  c.include SSLHelper
  c.include PebbleHelper
end
