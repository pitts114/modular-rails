# frozen_string_literal: true

require "rspec"
require "net/http"
require_relative "../lib/vault_client"

describe VaultClient::VaultClient do
  let(:host) { "localhost" }
  let(:port) { 3000 }
  let(:api_secret) { "testsecret" }
  let(:uri_instance) { double(:uri) }
  let(:uri_class) { double(:uri_http, build: uri_instance) }
  let(:http_post_instance) { double(:net_http_post) }
  let(:http_post_class) { double(:net_http_post, new: http_post_instance) }
  let(:json_module) { JSON }
  let(:http_class) { double(:net_http) }
  let(:http_instance) { double(:http_instance) }

  subject do
    described_class.new(
      host: host,
      port: port,
      api_secret: api_secret,
      uri_class: uri_class,
      http_post_class: http_post_class,
      http_class: http_class,
      json_module: json_module
    )
  end

  before do
    allow(http_post_instance).to receive(:[]=)
    allow(http_post_instance).to receive(:body=)
    allow(uri_instance).to receive(:hostname).and_return(host)
    allow(uri_instance).to receive(:port).and_return(port)
  end

  describe "#sign_msg" do
    it "returns the signature on success and calls request on http instance with req" do
      response = Net::HTTPOK.new("1.1", "200", "OK")
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, '{"signature":"sig"}')
      allow(http_class).to receive(:start).and_yield(http_instance)
      allow(http_instance).to receive(:request).and_return(response)
      expect(http_instance).to receive(:request) do |req|
        expect(req).to eq(http_post_instance)
      end.and_return(response)
      expect(subject.sign_msg(address: "0x123", message: "hi")).to eq("signature" => "sig")
    end

    it "raises an error if the response is not success" do
      response = Net::HTTPNotFound.new("1.1", "404", "Not Found")
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, '{"error":"Key not found"}')
      allow(http_class).to receive(:start).and_return(response)
      expect {
        subject.sign_msg(address: "0x123", message: "hi")
      }.to raise_error(VaultClient::Error, /Key not found/)
    end

    it "raises an error with raw body if response is not JSON" do
      response = Net::HTTPInternalServerError.new("1.1", "500", "Internal Server Error")
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, "Internal server error")
      allow(http_class).to receive(:start).and_return(response)
      expect {
        subject.sign_msg(address: "0x123", message: "hi")
      }.to raise_error(VaultClient::Error, /Internal server error/)
    end
  end

  describe "#sign_tx" do
    it "returns the signed transaction on success" do
      response = Net::HTTPOK.new("1.1", "200", "OK")
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, '{"signed_transaction":"0xsignedtx"}')
      allow(http_class).to receive(:start).and_return(response)
      expect(subject.sign_tx(address: "0x123", tx: { foo: "bar" })).to eq("signed_transaction" => "0xsignedtx")
    end
  end
end
