module Pushr
  class FeedbackWns < Pushr::Feedback
    attr_accessor :device, :follow_up, :failed_at
    validates :follow_up, inclusion: { in: %w(delete), message: '%{value} is not a valid follow-up' }

    def to_hash
      { type: 'Pushr::FeedbackWns', app: app, device: device, follow_up: follow_up, failed_at: failed_at }
    end
  end
end
