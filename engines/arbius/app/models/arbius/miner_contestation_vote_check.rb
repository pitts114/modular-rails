module Arbius
  class MinerContestationVoteCheck < Arbius::ApplicationRecord
    validates :task_id, presence: true, uniqueness: true
  end
end
