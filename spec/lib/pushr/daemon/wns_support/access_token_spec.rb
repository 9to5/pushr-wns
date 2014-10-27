require 'spec_helper'
require 'pushr/configuration_wns'
require 'pushr/daemon/wns_support/access_token'

describe Pushr::Daemon::WnsSupport::AccessToken do
  subject { Pushr::Daemon::WnsSupport::AccessToken.new(config) }

  describe 'receives token' do
    let(:config) do
      Pushr::ConfigurationWns.new(app: 'app_name', connections: 2, enabled: true, client_id: 'test',
                                  client_secret: 'secret')
    end

    it 'succesful', :vcr do
      expect(subject.get).to eql('acces_token')
    end
  end
end
