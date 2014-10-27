module Pushr
  class MessageWnsToast < Pushr::MessageWns
    def initialize(attributes = {})
      super(attributes)
      self.content_type = 'text/xml'
      self.x_wns_type = 'wns/toast'
    end
  end
end
