module Pushr
  module Daemon
    module WnsSupport
      class ConnectionError < StandardError; end

      class ConnectionWns
        attr_reader :response, :name
        IDLE_PERIOD = 5 * 60

        def initialize(app_name, access_token, i)
          @app_name = app_name
          @access_token = access_token
          @name = "#{app_name}: ConnectionWns #{i}"
        end

        def write(message)
          retry_count = 0
          begin
            response = notification_request(message)
            handle_error_response(response, message) unless response.code.eql? '200'
          rescue => e
            retry_count += 1
            retry if retry_count < 10
            raise e
          end
        end

        private

        # http://msdn.microsoft.com/en-us/library/windows/apps/hh465435.aspx
        def handle_error_response(response, message)
          case response.code.to_i
          when 403
            # TODO: retry with new credentials
          when 404, 410
            Pushr::FeedbackWns.create(app: @app_name, device: message.channel_uri, follow_up: 'delete',
                                      failed_at: Time.now)
          when 406
            # TODO: Throttle
          end

          Pushr::Daemon.logger.error("[#{@name}] #{response.code} #{response.message}")
        end

        def notification_request(message)
          uri = URI.parse(message.channel_uri)
          connect(uri) unless @last_use
          post(uri, message.data, headers(message))
        end

        def post(uri, data, headers, retry_count = 0)
          reconnect_idle if idle_period_exceeded?

          begin
            response = @connection.post("#{uri.path}?#{uri.query}", data, headers)
            @last_use = Time.now
          rescue EOFError, Errno::ECONNRESET, Timeout::Error => e
            retry_count += 1
            Pushr::Daemon.logger.error("[#{@name}] Lost connection to #{PUSH_URL} (#{e.class.name}), reconnecting ##{retry_count}...")
            if retry_count <= 3
              reconnect
              sleep 1
              retry
            end
            raise ConnectionError, "#{@name} tried #{retry_count - 1} times to reconnect but failed (#{e.class.name})."
          end

          response
        end

        def open_http(host, port)
          http = Net::HTTP.new(host, port)
          http.use_ssl = true
          http
        end

        def headers(message)
          { 'Authorization' => "Bearer #{@access_token.get}",
            'Content-type' => message.content_type,
            'Content-length' => "#{message.data.bytes.count}",
            'X-WNS-RequestForStatus' => 'true',
            'X-WNS-Type' => message.x_wns_type }
        end

        def connect(uri)
          @last_use = Time.now
          @connection = open_http(uri.host, uri.port)
          @connection.start
          Pushr::Daemon.logger.info("[#{@name}] Connected to #{uri.scheme}://#{uri.host}")
        end

        def idle_period_exceeded?
          # Timeout on the http connection is 5 minutes, reconnect after 5 minutes
          @last_use + IDLE_PERIOD < Time.now
        end

        def reconnect_idle
          Pushr::Daemon.logger.info("[#{@name}] Idle period exceeded, reconnecting...")
          reconnect
        end

        def reconnect
          @connection.finish
          @last_use = Time.now
          @connection.start
        end
      end
    end
  end
end
