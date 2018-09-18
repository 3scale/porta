require 'test_helper'

class ValidateEmailInterceptorTest < ActionMailer::TestCase

  class DoubleMailer < ActionMailer::Base
    def new_account(to: nil, bcc: nil)
      mail(subject: 'New account', to: to, bcc: bcc, from: 'foo@example.net') do |format|
        format.text { render plain: 'New account' }
      end
    end
  end

  def test_validate_to_attribute
    assert_difference(ActionMailer::Base.deliveries.method(:count), +1) do
      DoubleMailer.new_account(to: 'bar@example.com').deliver_now
    end

    assert_difference(ActionMailer::Base.deliveries.method(:count), +1) do
      DoubleMailer.new_account(bcc: ['bar@example.com']).deliver_now
    end

    assert_no_difference(ActionMailer::Base.deliveries.method(:count)) do
      DoubleMailer.new_account(to: nil, bcc: nil).deliver_now
    end
  end
end
