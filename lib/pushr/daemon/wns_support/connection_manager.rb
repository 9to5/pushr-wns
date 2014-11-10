module Pushr
  module Daemon
    module WnsSupport
      class ConnectionManager
        def initialize(app_name, access_token, i)
          @pool = {}
          @app_name = app_name
          @access_token = access_token
          @i = i
        end

        def get(uri)
          key = "#{uri.scheme}://#{uri.host}"
          if @pool.key? key
            @pool[key]
          else
            @pool[key] = ConnectionWns.new(@app_name, @access_token, @i)
          end
        end

        def write(message)
          uri = URI.parse(message.channel_uri)
          connection = get(uri)
          connection.write(message)
        end

        def size
          @pool.size
        end
      end
    end
  end
end
