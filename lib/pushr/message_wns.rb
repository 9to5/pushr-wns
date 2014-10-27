module Pushr
  class MessageWns < Pushr::Message
    POSTFIX = 'wns'

    attr_accessor :channel_uri, :data, :content_type, :x_wns_type
    validates :channel_uri, :data, :content_type, :x_wns_type, presence: true
    validates :content_type, inclusion: { in: ['text/xml', 'application/octet-stream'] }
    validates :x_wns_type, inclusion: { in: ['wns/toast', 'wns/badge', 'wns/tile', 'wns/raw'] }
    validate :channel_uri_domain
    validate :data_size

    def channel_uri_domain
      return if channel_uri && URI.parse(channel_uri).host.end_with?('notify.windows.com')
      errors.add(:channel_uri, 'channel_uri domain should end with \'notify.windows.com\'')
    end

    def data_size
      errors.add(:data, 'is more thank 5000 bytes') if data && data.bytes.count > 5000
    end

    def to_message
      hsh = {}
      %w(channel_uri data).each do |variable|
        hsh[variable] = send(variable) if send(variable)
      end
      MultiJson.dump(hsh)
    end

    def to_hash
      hsh = { type: self.class.to_s, app: app, channel_uri: channel_uri, data: data, content_type: content_type,
              x_wns_type: x_wns_type }
      hsh[Pushr::Core.external_id_tag] = external_id if external_id
      hsh
    end
  end
end
