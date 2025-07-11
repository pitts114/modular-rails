# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "vault_client"
  spec.version       = "0.1.0"
  spec.authors       = [ "Foo Bar" ]
  spec.email         = [ "foo@bar.com" ]

  spec.summary       = "Ruby client for the Vault signing service API."
  spec.description   = "A simple Ruby client for interacting with the Vault Sinatra app that signs Ethereum messages and transactions."
  spec.homepage      = "https://github.com/pitts114/vault_client"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = [ "lib" ]

  spec.add_runtime_dependency "json"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "eth"
  spec.add_development_dependency "dotenv"
end
