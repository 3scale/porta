require 'test_helper'

class Provider::SignupsHelperTest < ActionView::TestCase

  attr_reader :signup_success_data

  def setup
    @signup_success_data = {}
  end

  test "#phrase_email with email" do
    @signup_success_data = { email: 'foo@example.com' }
    assert_match 'foo@example.com', phrase_email
  end

  test "#phrase_email with gmail" do
    @signup_success_data = {email: "foo@gmail.com"}

    assert_match "foo@gmail.com", phrase_email
    assert_match "your Gmail inbox", phrase_email
  end

  test "#phrase_email without email" do
    assert_match "sent you an email", phrase_email
  end

  test "#phrase_first_name with first name" do
    @signup_success_data = {first_name: "foo"}
    assert_match "foo", phrase_first_name
  end

  test "#phrase_first_name without first name" do
    assert_match "Thank you", phrase_first_name
  end

end
