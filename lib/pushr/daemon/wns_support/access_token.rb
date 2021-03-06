# In the authentication with WNS, the cloud service submits an HTTP request over Secure Sockets Layer (SSL). The
# parameters are supplied in the "application/x-www-for-urlencoded" format. Supply your Package SID in the  "client_id"
# field and your secret key in the "client_secret" field. For syntax details, see the access token request reference.

module Pushr
  module Daemon
    module WnsSupport
      class AuthenticationError < StandardError; end

      class AccessToken
        def initialize(configuration)
          @configuration = configuration
          @expires_in = Time.now
          @semaphore = Mutex.new
        end

        def get
          @semaphore.synchronize { request_token if expired? || @access_token.nil? }
          @access_token
        end

        def expired?
          Time.now > @expires_in
        end

        def request_token
          uri = URI('https://login.live.com/accesstoken.srf')
          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data(params)
          response = http(uri).request(request)
          response_hsh = MultiJson.load(response.body)
          if response.code.to_i != 200
            fail AuthenticationError, response_hsh['error_description']
          else
            process_response(response_hsh)
          end
        end

        def http(uri)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http
        end

        def process_response(params)
          @expires_in = Time.now + params['expires_in']
          @access_token = params['access_token']
        end

        def params
          { grant_type: 'client_credentials', scope: 'notify.windows.com', client_id: @configuration.client_id,
            client_secret: @configuration.client_secret }
        end
      end
    end
  end
end
