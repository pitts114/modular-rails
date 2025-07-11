# frozen_string_literal: true

FactoryBot.define do
  factory :arbius_solution_submitted_event, class: 'Arbius::SolutionSubmittedEvent' do
    arbius_ethereum_event_details { create(:arbius_ethereum_event_detail) }
    address { '0xd8da6bf26964af9d7eed9e03e53415d37aa96045' }
    task { 'task_1' }
  end
end
