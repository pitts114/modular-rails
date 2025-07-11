module Arbius
  module Public
    class ValidatorsService
      def initialize(
        model: Arbius::Validator
      )
        @model = model
      end

      def validators
        @model.all
      end
    end
  end
end
