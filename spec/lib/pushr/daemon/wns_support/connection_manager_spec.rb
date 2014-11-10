require 'spec_helper'
require 'pushr/daemon'
require 'pushr/daemon/logger'
require 'pushr/configuration_wns'
require 'pushr/message_wns'
require 'pushr/daemon/wns_support/access_token'
require 'pushr/daemon/wns_support/connection_wns'
require 'pushr/daemon/wns_support/connection_manager'

describe Pushr::Daemon::WnsSupport::ConnectionManager do
  before(:each) do
    Pushr::Core.configure do |config|
      config.redis = ConnectionPool.new(size: 1, timeout: 1) { MockRedis.new }
    end

    logger = double('logger')
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
    allow(logger).to receive(:warn)
    Pushr::Daemon.logger = logger
  end

  subject { Pushr::Daemon::WnsSupport::ConnectionManager.new('app_name', access_token, 1) }
  let(:access_token) { double('Pushr::Daemon::WnsSupport::AccessToken', get: 'access_token') }

  let(:message) do
    hsh = { app: 'app_name', channel_uri: 'https://db3.notify.windows.com/?token=token',
            data: '<toast launch=""><visual lang="en-US"><binding template="ToastImageAndText01"><image id="1" '\
                  'src="World" /><text id="1">Hello</text></binding></visual></toast>',
            content_type: 'text/xml', x_wns_type: 'wns/toast' }
    Pushr::MessageWns.new(hsh)
  end

  let(:message2) do
    hsh = { app: 'app_name', channel_uri: 'https://db4.notify.windows.com/?token=token',
            data: '<toast launch=""><visual lang="en-US"><binding template="ToastImageAndText01"><image id="1" '\
                  'src="World" /><text id="1">Hello</text></binding></visual></toast>',
            content_type: 'text/xml', x_wns_type: 'wns/toast' }
    Pushr::MessageWns.new(hsh)
  end

  describe 'creates first connection' do
    it 'succesful', :vcr do
      subject.write(message)
      expect(subject.size).to eql(1)
    end
  end

  describe 'creates multiple connections' do
    it 'succesful', :vcr do
      subject.write(message)
      subject.write(message2)
      expect(subject.size).to eql(2)
    end
  end
end
