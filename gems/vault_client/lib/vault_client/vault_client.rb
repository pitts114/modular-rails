# frozen_string_literal: true

require "net/http"
require "json"

module VaultClient
  class Error < StandardError; end

  class VaultClient
    attr_reader :host, :port, :api_secret, :uri_class, :http_post_class, :http_class, :json_module

    def initialize(
      host:,
      port: 3000,
      api_secret:,
      uri_class: URI::HTTP,
      http_post_class: Net::HTTP::Post,
      http_class: Net::HTTP,
      json_module: JSON
    )
      @host = host
      @port = port
      @api_secret = api_secret
      @uri_class = uri_class
      @http_post_class = http_post_class
      @http_class = http_class
      @json_module = json_module
    end

    def sign_tx(address:, tx:)
      post("/sign_tx", { address: address, tx: tx })
    end

    def sign_msg(address:, message:)
      post("/sign_msg", { address: address, message: message })
    end

    private

    def post(path, body)
      uri = uri_class.build(host: host, port: port, path: path)
      req = http_post_class.new(uri)
      req["Authorization"] = "Bearer #{api_secret}"
      req["Content-Type"] = "application/json"
      req.body = json_module.dump(body)

      res = http_class.start(uri.hostname, uri.port) { |http| http.request(req) }
      handle_response(res)
    end

    def handle_response(res)
      case res
      when Net::HTTPSuccess
        json_module.parse(res.body)
      else
        begin
          error = json_module.parse(res.body)
        rescue JSON::ParserError
          error = { "error" => res.body }
        end
        raise Error, "Vault API error: #{error['error']} (status #{res.code})"
      end
    end
  end
end
