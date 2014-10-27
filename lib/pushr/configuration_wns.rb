module Pushr
  class ConfigurationWns < Pushr::Configuration
    attr_accessor :client_id, :client_secret
    validates :client_id, :client_secret, presence: true

    def name
      :wns
    end

    def to_hash
      { type: self.class.to_s, app: app, enabled: enabled, connections: connections, client_id: client_id,
        client_secret: client_secret }
    end
  end
end
