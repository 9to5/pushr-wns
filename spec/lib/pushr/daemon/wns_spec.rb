require 'spec_helper'
require 'pushr/daemon/wns'
require 'pushr/daemon/wns_support/connection_wns'

describe Pushr::Daemon::Wns do
  let(:wns) { Pushr::Daemon::Wns.new(test: 'test') }

  describe 'responds to' do
    it 'configuration' do
      expect(wns.configuration).to eql(test: 'test')
    end
  end
end
