module Arbius
  module Public
    class ContestationsService
      def initialize(
        model: Arbius::ContestationSubmittedEvent
      )
        @model = model
      end

      def contestation(task_id:)
        @model.find_by(task_id: task_id)
      end
    end
  end
end
