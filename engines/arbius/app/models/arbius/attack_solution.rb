module Arbius
  class AttackSolution < Arbius::ApplicationRecord
    validates :task, presence: true
  end
end
