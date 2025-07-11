require "json"
require "eth"

module EthEventUtils
  # Computes the topic0 for a given event name and ABI (array of event hashes)
  def self.topic0_for(event_name:, abi:)
    event = abi.find { |e| e["type"] == "event" && e["name"] == event_name }
    raise "Event '#{event_name}' not found in ABI" unless event
    types = event["inputs"].map { |i| i["type"] }
    signature = "#{event_name}(#{types.join(',')})"
    "0x" + Eth::Util.keccak256(signature).unpack1("H*")
  end
end
