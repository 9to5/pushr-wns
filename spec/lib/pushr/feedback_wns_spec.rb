require 'spec_helper'
require 'pushr/feedback_wns'

describe Pushr::FeedbackWns do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'create' do
    it 'should create a feedback' do
      feedback = Pushr::FeedbackWns.new(app: 'app_name', device: 'ab' * 20, follow_up: 'delete', failed_at: Time.now)
      expect(feedback.app).to eql('app_name')
    end
  end

  describe 'save' do
    let!(:feedback) do
      Pushr::FeedbackWns.create(app: 'app_name', device: 'ab' * 20, follow_up: 'delete', failed_at: Time.now)
    end
    it 'should save a feedback' do
      expect(Pushr::Feedback.next.class).to eql(Pushr::FeedbackWns)
    end
  end
end
