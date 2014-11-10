require 'spec_helper'
require 'pushr/configuration_wns'
require 'pushr/daemon/wns_support/access_token'

describe Pushr::Daemon::WnsSupport::AccessToken do
  subject { Pushr::Daemon::WnsSupport::AccessToken.new(config) }

  let(:config) do
    Pushr::ConfigurationWns.new(app: 'app_name', connections: 2, enabled: true, client_id: client_id,
                                client_secret: client_secret)
  end
  describe 'receives token' do
    let(:client_id) { 'test' }
    let(:client_secret) { 'secret' }
    it 'succesful', :vcr do
      expect(subject.get).to eql('access_token')
    end
  end

  describe 'does not receive token' do
    let(:client_id) { 'invalid_test' }
    let(:client_secret) { 'invalid_secret' }
    it 'unsuccesful', :vcr do
      expect { subject.get }.to raise_error(Pushr::Daemon::WnsSupport::AuthenticationError)
    end
  end
end
