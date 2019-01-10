require 'test_helper'

class ApiDocs::MailerTest < ActionMailer::TestCase
  test "it includes base path" do
    base_path = 'http://example.com'
    account = FactoryBot.build(:account)
    service = ApiDocs::Service.new(:body => {:basePath => base_path}.to_json, :account => account)

    mail = ApiDocs::Mailer.new_path_notification(service)

    assert_match base_path, mail.body.to_s
  end

end
