require 'test_helper'

# :reek:UncommunicativeVariableName
class ThreeScale::SemanticFormBuilderTest < ActionView::TestCase

  include Formtastic::Helpers::FormHelper

  class Dummy
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    attr_reader :errors, :title, :author

    def initialize
      @errors = ActiveModel::Errors.new(self)
      @errors.add(:title, 'error 1')
      @errors.add(:title, 'error 2')
      @errors.add(:author, 'error 1')
      @errors.add(:author, 'error 2')
      @title = 'title'
      @author = 'author'
    end
  end

  def test_select_input
    user = FactoryBot.create(:simple_user)

    semantic_form_for(user, url: '', as: :dummy) do |f|

      f.input(:notifications, as: :select).html_safe
    end
  end

  test 'inline errors' do
    dummy = Dummy.new

    #
    # Normal behaviour
    #
    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(dummy, :url => '', as: :dummy) do |f|
        f.input(:title).html_safe
      end
    )

    # test errors as sentence
    html_doc = Nokogiri::HTML4(buffer.output)
    assert_equal 'error 1 and error 2', html_doc.css('li#dummy_title_input p.inline-errors').text


    #
    # Should be independent and no affect to other fields
    #
    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(dummy, :url => '', as: :dummy) do |f|
        f.input(:title).html_safe +
        f.input(:author).html_safe
      end
    )

    html_doc = Nokogiri::HTML4(buffer.output)

    # errors of title
    assert html_doc.css('li#dummy_title_input p.inline-errors').present?

    # errors of author as sentence
    assert_equal 'error 1 and error 2', html_doc.css('li#dummy_author_input p.inline-errors').text
  end

  test 'commit_button' do
    app = FactoryBot.create(:application)
    semantic_form_for app, url: '' do |form|
      button = form.commit_button nil, button_html: { class: 'foo' }
      assert Nokogiri.parse(button).css('button.pf-c-button.pf-m-primary.foo').length.positive?

      button = form.commit_button
      assert Nokogiri.parse(button).css('button.pf-c-button.pf-m-primary').length.positive?

      button = form.commit_button nil, button_html: { class: 'pf-c-button pf-m-primary' }
      assert Nokogiri.parse(button).css('button.pf-c-button.pf-m-primary').length.positive?
    end
  end

  test 'bot protection' do
    SemanticFormBuilder.any_instance.stubs(:bot_protection_enabled?).returns(true)
    account = FactoryBot.create(:buyer_account)
    buffer = TestOutputBuffer.new
    buffer.concat(semantic_form_for(account, url: '', &:bot_protection_inputs))

    html_doc = Nokogiri::HTML4(buffer.output)

    assert html_doc.css('.g-recaptcha').present?
  end

  test 'error_messages returns empty string when no errors' do
    user = FactoryBot.create(:simple_user)
    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(user, url: '', as: :user, &:error_messages)
    )
    html_doc = Nokogiri::HTML4(buffer.output)
    assert_empty html_doc.css('#errorExplanation')
  end

  test 'error_messages displays single object errors' do
    dummy = Dummy.new
    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(dummy, url: '', as: :dummy, &:error_messages)
    )

    html_doc = Nokogiri::HTML4(buffer.output)
    assert html_doc.css('#errorExplanation').present?
    assert html_doc.css('#errorExplanation ul li').length.positive?

    error_texts = html_doc.css('#errorExplanation ul li').map(&:text)
    assert_includes error_texts, 'Title error 1'
    assert_includes error_texts, 'Title error 2'
    assert_includes error_texts, 'Author error 1'
    assert_includes error_texts, 'Author error 2'
  end

  test 'error_messages handles multiple objects with errors' do
    dummy1 = Dummy.new
    dummy2 = Dummy.new

    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(dummy1, url: '', as: :dummy) do |form|
        form.send(:error_messages_for, :dummy1, :dummy2, object: [dummy1, dummy2])
      end
    )

    html_doc = Nokogiri::HTML4(buffer.output)
    assert html_doc.css('#errorExplanation').present?
    assert_equal 8, html_doc.css('#errorExplanation ul li').length
  end

  test 'error_messages ignores specific messages' do
    # Create an object with errors including ignored ones
    account = FactoryBot.build(:simple_account)
    account.errors.add(:base, 'Account is invalid')
    account.errors.add(:base, 'Bought cinstances is invalid')
    account.errors.add(:name, 'cannot be blank')

    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(account, url: '', as: :account, &:error_messages)
    )

    html_doc = Nokogiri::HTML4(buffer.output)
    error_texts = html_doc.css('#errorExplanation ul li').map(&:text)

    assert_not_includes error_texts, 'Account is invalid'
    assert_not_includes error_texts, 'Bought cinstances is invalid'
    assert_includes error_texts, 'Name cannot be blank'
  end

  test 'error_messages preserves error message content and structure' do
    dummy = Dummy.new

    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(dummy, url: '', as: :dummy, &:error_messages)
    )

    html_doc = Nokogiri::HTML4(buffer.output)

    assert html_doc.css('#errorExplanation h2').present?, 'Should have header'
    assert html_doc.css('#errorExplanation p').present?, 'Should have message paragraph'
    assert html_doc.css('#errorExplanation ul').present?, 'Should have error list'

    assert_equal 4, html_doc.css('#errorExplanation ul li').count, 'All errors should be wrapped in a li'
  end
end
