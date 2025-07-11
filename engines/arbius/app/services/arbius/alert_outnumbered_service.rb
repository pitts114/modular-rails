module Arbius
  class AlertOutnumberedService
    def initialize(pagerduty: Pagerduty.build(integration_key: ENV['PAGERDUTY_API_KEY'], api_version: 2))
      @pagerduty = pagerduty
    end

    def call
      return unless Rails.env.production?
      @pagerduty.trigger(summary: 'Outnumbered in Contestation', source:  "acc", severity: "critical")
    end
  end
end
