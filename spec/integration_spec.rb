require 'spec_helper'

describe 'Full integration test' do
  let(:domains) { %w[example.com *.example.com] }

  let(:private_key) { generate_private_key }

  let(:client) do
    client = Acme::Client.new(private_key: private_key, directory: DIRECTORY_URL)
    client.new_account(contact: 'mailto:info@example.com', terms_of_service_agreed: true)
    client
  end

  let(:order) do
    client.new_order(identifiers: domains)
  end

  let(:csr) { Acme::Client::CertificateRequest.new(names: domains) }

  def wait_until(seconds: 5)
    Timeout.timeout(5) do
      sleep 0.1 until yield
    end
  end

  it 'happy paths' do
    http = order.authorizations.find {|a| !a.wildcard }.http
    run_challenge http  do
      http.request_validation
    end

    dns = order.authorizations.find {|a| a.wildcard }.dns
    run_challenge dns, domain: 'example.com' do
      dns.request_validation
    end

    retry_until condition: -> { order.status == 'ready'} do
      order.reload
    end

    order.finalize csr: csr

    retry_until condition: -> { order.status == 'valid'} do
      order.reload
    end

    expect(order.certificate).to be
  end
end
