module Arbius
  class AlertValidatorDepositService
    def initialize(pagerduty: Pagerduty.build(integration_key: ENV['PAGERDUTY_API_KEY'], api_version: 2))
      @pagerduty = pagerduty
    end

    def call
      return unless Rails.env.production?
      @pagerduty.trigger(summary: 'Validator deposit alert, stopping auto mining', source:  "acc", severity: "critical")
    end
  end
end
