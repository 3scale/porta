require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class MessagesHelperTest < ActionView::TestCase
  include Buyers::AccountsHelper
  attr_accessor :current_account

  def can?(*)
    true
  end

  context 'message_receiver' do
    setup do
      @buyer_receiver = FactoryBot.create(:buyer_account)
      @provider_receiver = FactoryBot.create(:account)
    end

    should 'return link to buyer for buyer recipient' do
      message = FactoryBot.create(:message, :to => [@buyer_receiver])
      assert_equal link_to(@buyer_receiver.org_name, admin_buyers_account_path(@buyer_receiver), :title => account_title(@buyer_receiver)),
                   message_receiver(message)
    end

    should 'return org name for provider recipient' do
      message = FactoryBot.create(:message, :to => [@provider_receiver])
      assert_equal @provider_receiver.org_name,
                   message_receiver(message)
    end

    should 'return (deleted) for non existing recipient' do
      message = FactoryBot.create(:message, :to => [@buyer_receiver])
      message.recipients.first.receiver = nil
      assert_equal "<span class=\"deleted\">(deleted)</span>", message_receiver(message)
      message.recipients = []
      assert_equal "<span class=\"deleted\">(deleted)</span>", message_receiver(message)
    end

    should 'not return org names for message with multi recipients' do
      message = FactoryBot.create(:message, :to => [@buyer_receiver, @provider_receiver])
      assert_equal "Multiple Recipients", message_receiver(message)
    end
  end

  context 'message_sender' do
    setup do
      @buyer_sender = FactoryBot.create(:buyer_account)
      @provider_sender = FactoryBot.create(:account)
    end

    should 'return link to buyer account' do
      message_from_buyer = FactoryBot.create(:message, :sender => @buyer_sender)
      assert_equal link_to(@buyer_sender.org_name, admin_buyers_account_path(@buyer_sender), :title => account_title(@buyer_sender)),
                   message_sender(message_from_buyer)
    end

    should 'return org name of provider account' do
      message_from_provider = FactoryBot.create(:message, :sender => @provider_sender)
      assert_equal @provider_sender.org_name,
                   message_sender(message_from_provider)
    end

    should 'return (deleted) for non existing sender' do
      message = FactoryBot.create(:message, :to => [@buyer_sender])
      message.sender = nil
      assert_equal "<span class=\"deleted\">(deleted)</span>",
                   message_sender(message)
    end
  end

  def test_one
    assert_equal %q{Some <a href="http://google.com">http://google.com</a> text},
                 hyperlink_urls('Some http://google.com text')
  end

  def test_text_with_incomplete_link
    assert_equal %q{sth sth sth <a href="http://duzadupa">http://duzadupa</a> sth sth},
                 hyperlink_urls('sth sth sth http://duzadupa sth sth')
  end

  def test_text_without_links
    assert_equal %{sth sth sth sth},
                 hyperlink_urls('sth sth sth sth')
  end

  def test_text_with_two_links
    assert_equal %{Some <a href="http://google.com">http://google.com</a> text <a href="http://3scale.net">http://3scale.net</a> text2},
                 hyperlink_urls('Some http://google.com text http://3scale.net text2')
  end


  def test_replace_links_with_html_escapes_html
    text = hyperlink_urls('<b>text</b>')

    assert_equal '&lt;b&gt;text&lt;/b&gt;', text
    assert text.html_safe?
  end
  #

  def test_if_removes_dots_from_end_of_links
    assert_equal %{Some <a href="http://google.com">http://google.com</a>. text},
                 hyperlink_urls('Some http://google.com. text')
  end

  def test_if_unusual_unusual_caracters_around_url_pass
    assert_equal %{Some <a href="http://google.com">http://google.com</a>)) text},
                 hyperlink_urls('Some http://google.com)) text')
  end

  def test_if_other_unusual_caracters_around_url_pass
    assert_equal %{Some <a href="http://google.com">http://google.com</a>]] text},
                 hyperlink_urls('Some http://google.com]] text')
  end

  def test_if_links_staring_with_https_are_highlighted_correctly
    assert_equal %{Some <a href="https://google.com">https://google.com</a> text},
                 hyperlink_urls('Some https://google.com text')
  end

  def test_if_links_with_colon_at_the_end_are_shown_properly_with_https_links
    assert_equal %{Some <a href="https://google.com">https://google.com</a>: text},
                 hyperlink_urls('Some https://google.com: text')
  end

  def test_if_links_with_colon_at_the_end_are_shown_properly_with_http_links
    assert_equal %{Some <a href="http://google.com">http://google.com</a>: text},
                 hyperlink_urls('Some http://google.com: text')
  end

  # this is regression test for: https://github.com/3scale/system/issues/4819
  def test_if_random_word_with_colon_at_the_end_is_not_treated_like_link
    assert_equal %{Some random word:},
                 %{Some random word:}
  end

end
