module Pushr
  module Daemon
    class Wns
      attr_accessor :configuration, :handlers

      def initialize(options)
        @configuration = options
        @handlers = []
      end

      def start
        access_token = Pushr::Daemon::WnsSupport::AccessToken.new(configuration)
        configuration.connections.times do |i|
          connection = WnsSupport::ConnectionManager.new(configuration.name, access_token, i + 1)
          handler = MessageHandler.new("pushr:#{configuration.key}", connection, configuration.app, i + 1)
          handler.start
          @handlers << handler
        end
      end

      def stop
        @handlers.map(&:stop)
      end
    end
  end
end
