require 'spec_helper'
require 'pushr/daemon'
require 'pushr/wns'
require 'pushr/daemon/logger'
require 'pushr/message_wns'
require 'pushr/configuration_wns'
require 'pushr/daemon/delivery_error'

describe Pushr::Daemon::WnsSupport::ConnectionWns do
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

  let(:access_token) { double('Pushr::Daemon::WnsSupport::AccessToken', get: 'access_token') }
  let(:message) do
    hsh = { app: 'app_name', channel_uri: 'https://db3.notify.windows.com/?token=token',
            data: '<toast launch=""><visual lang="en-US"><binding template="ToastImageAndText01"><image id="1" '\
                  'src="World" /><text id="1">Hello</text></binding></visual></toast>' }
    Pushr::MessageWnsToast.new(hsh)
  end
  let(:connection) { Pushr::Daemon::WnsSupport::ConnectionWns.new('app_name', access_token, 1) }

  describe 'sends a message' do

    it 'succesful', :vcr do
      connection.write(message)
      # TODO: expect(connection.write(message).code).to eql '200'
    end
  end
end
