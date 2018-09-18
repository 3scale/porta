class ThreeScale::EmailSanitizer

  def initialize(to)
    if to.present?
      @to = to
    else
      raise ArgumentError.new('Missing address to which all emails should go')
    end
  end

  def delivering_email(message)
    message.header['X-3scale-To'] = message.to
    message.header['X-3scale-Cc'] = message.cc
    message.header['X-3scale-Bcc'] = message.bcc

    message.to = @to
    message.cc = nil
    message.bcc = nil
  end

end
