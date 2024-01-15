require 'test_helper'

class ThreeScale::SemanticFormBuilderTest < ActionView::TestCase

  include Formtastic::Helpers::FormHelper

  class Dummy
    extend ActiveModel::Naming

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
    buffer.concat(semantic_form_for(account, url: '', &:bot_protection))

    html_doc = Nokogiri::HTML4(buffer.output)

    assert html_doc.css('.g-recaptcha').present?
  end
end
