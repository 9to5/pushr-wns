module Pushr
  module Daemon
    module WnsSupport
      class ConnectionError < StandardError; end

      class ConnectionWns
        attr_reader :response, :name, :configuration

        def initialize(configuration, i)
          @configuration = configuration
          @access_token = AccessToken.new(@configuration)
          @name = "#{@configuration.app}: ConnectionWns #{i}"
        end

        def connect
        end

        def write(message)
          response = notification_request(message)
          handle_response(response) unless response.code.eql? '200'
        end

        private

        # http://msdn.microsoft.com/en-us/library/windows/apps/hh465435.aspx
        def handle_error_response(response)
          case response.code.to_i
          when 403
            # TODO: retry with new credentials
          when 404, 410
            # TODO: FEEABACK
          when 406
            # TODO: Throttle
          end

          Pushr::Daemon.logger.error("[#{@name}] #{response.code} #{response.message}")
        end

        def notification_request(message)
          uri = URI.parse(message.channel_uri)
          req = Net::HTTP::Post.new("#{uri.path}?#{uri.query}", headers(message))
          req.body = message.data
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.request(req)
        end

        def headers(message)
          { 'Authorization' => "Bearer #{@access_token.get}",
            'Content-type' => message.content_type,
            'Content-length' => "#{message.data.bytes.count}",
            'X-WNS-RequestForStatus' => 'true',
            'X-WNS-Type' => message.x_wns_type }
        end
      end
    end
  end
end
