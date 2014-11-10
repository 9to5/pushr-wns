module Pushr
  module Daemon
    module WnsSupport
      class ConnectionManager
        attr_accessor :name
        def initialize(app_name, access_token, i)
          @pool = {}
          @app_name = app_name
          @access_token = access_token
          @i = i
          @name = "#{app_name}: ConnectionWns #{i}"
        end

        def get(uri)
          key = "#{uri.scheme}://#{uri.host}"
          unless @pool.key? key
            @pool[key] = ConnectionWns.new(@app_name, @access_token, @i)
          end
          @pool[key]
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
