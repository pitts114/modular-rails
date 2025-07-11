module Arbius
  class ValidatorRepository
    def initialize(validator_model: Arbius::Validator)
      @validator_model = validator_model
    end

    def find_addresses_excluding(exclude_addresses:)
      @validator_model.where.not(address: exclude_addresses).order(:address).map(&:address)
    end
  end
end
