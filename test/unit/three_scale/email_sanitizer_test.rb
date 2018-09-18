require 'test_helper'
require 'mail'

class ThreeScale::EmailSanitizerTest < ActiveSupport::TestCase

  def setup
  end

  def test_requires_emails
    assert_raises(ArgumentError) do
      ThreeScale::EmailSanitizer.new
    end
  end

  def test_deliver_email
    message = Mail.new(to: "me@#{ThreeScale.config.superdomain}", cc: 'dangerous@michaeal.jackson', bcc: 'secret@door.se')
    sanitizer = ThreeScale::EmailSanitizer.new('black.hole@example.com')

    sanitizer.delivering_email(message)

    assert_equal ['black.hole@example.com'], message.to
    assert_nil message.cc
    assert_nil message.bcc
  end

  def test_deliver_email_custom_headers
    message = Mail.new(to: ['a@b.net', 'aa@bb.net'], cc: 'c@d.net', bcc: 'e@f.net')

    ThreeScale::EmailSanitizer.new('black.hole@example.com').delivering_email(message)

    assert_equal 'a@b.net, aa@bb.net', message['X-3scale-To'].to_s
    assert_equal 'c@d.net', message['X-3scale-Cc'].to_s
    assert_equal 'e@f.net', message['X-3scale-Bcc'].to_s
  end

end
