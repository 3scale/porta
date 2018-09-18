require 'test_helper'

class Dashboard::MessagesPresenterTest < Draper::TestCase

  LIMIT = Dashboard::MessagesPresenter::LIMIT

  def setup
    Timecop.freeze(DateTime.now.midday)
  end

  def teardown
    Timecop.return
  end

  def test_render_no_messages
    html = html_from_presenter(MessageRecipient.none)

    # we have no messages
    # we should see both titles
    assert_match title(:today), html
    assert_match title(:older), html
  end

  def test_render_only_todays_messages
    messages = create_messages
    html     = html_from_presenter(messages)

    # we have only today's messages
    # we should see only today title
    assert_match title(:today), html
    assert_not_match title(:older), html

    LIMIT.times do |n|
      assert html =~ /Alaska_#{n}/
    end
  end

  def test_render_older_messages
    messages = create_messages(DateTime.yesterday)
    html     = html_from_presenter(messages)

    # we have only yesterday's messages
    # we should see both titles
    assert_match title(:today), html
    assert_match title(:older), html

    LIMIT.times do |n|
      assert_match /Alaska_#{n}/, html
    end
  end

  private

  def create_messages(created_at = DateTime.now)
    message_ids = Array.new(LIMIT) do |n|
      FactoryGirl.create(:message, subject: "Alaska_#{n}", created_at: created_at).id
    end

    Message.where(id: message_ids)
  end

  def presenter
    self.class.to_s.sub(/Test$/,'').constantize
  end

  def html_from_presenter(messages)
    html = presenter.new(messages).render

    CGI.unescapeHTML(html.to_str)
  end

  def title(key)
    I18n.t("provider.admin.dashboards.show.#{key}")
  end
end
