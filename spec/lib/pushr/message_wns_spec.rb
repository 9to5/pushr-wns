require 'spec_helper'
require 'pushr/message_wns'

describe Pushr::MessageWns do

  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end
  end

  describe 'next' do
    it 'returns next message' do
      expect(Pushr::Message.next('pushr:app_name:wns')).to eql(nil)
    end
  end

  describe 'save' do
    let(:message) do
      hsh = { app: 'app_name', channel_uri: 'https://db3.notify.windows.com/?token=token',
              data: '<toast launch=""><visual lang="en-US"><binding template="ToastImageAndText01"><image id="1" '\
                    'src="World" /><text id="1">Hello</text></binding></visual></toast>',
              content_type: 'text/xml', x_wns_type: 'wns/toast' }
      Pushr::MessageWns.new(hsh)
    end

    it 'should return true' do
      expect(message.save).to eql true
    end

    it 'should save a message' do
      message.save
      expect(Pushr::Message.next('pushr:app_name:wns')).to be_kind_of(Pushr::MessageWns)
    end

    it 'should respond to to_message' do
      expect(message.to_message).to be_kind_of(String)
    end
  end
end
