module TestHelpers
  module Ssl
    def ssl=(value)
      self.env['HTTPS'] = value ? 'on' : nil
    end

    def ssl!
      self.ssl = true
    end
  end
end

ActionController::TestRequest.send(:include, TestHelpers::Ssl)
