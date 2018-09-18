require 'test_helper'

class ThreeScale::SemanticFormBuilderTest < ActionView::TestCase

  include Formtastic::SemanticFormHelper

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
    user = FactoryGirl.create(:simple_user)

    semantic_form_for(user, url: '', as: :dummy) do |f|

      f.input(:notifications, as: :select).html_safe
    end
  end

  test 'inline errors' do
    dummy = Dummy.new

    #
    # Inline errors
    #
    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(dummy, :url => '', as: :dummy) do |f|
        f.input(:title, inline_errors: :list).html_safe
      end
    )

    html_doc = Nokogiri::HTML(buffer.output)
    # errors as list
    assert html_doc.css('li#dummy_title_input ul.errors').present?


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
    html_doc = Nokogiri::HTML(buffer.output)
    assert_equal 'error 1 and error 2', html_doc.css('li#dummy_title_input p.inline-errors').text


    #
    # Should be independent and no affect to other fields
    #
    buffer = TestOutputBuffer.new
    buffer.concat(
      semantic_form_for(dummy, :url => '', as: :dummy) do |f|
        f.input(:title, inline_errors: :list).html_safe +
        f.input(:author).html_safe
      end
    )

    html_doc = Nokogiri::HTML(buffer.output)

    # errors of title as list
    assert html_doc.css('li#dummy_title_input ul.errors').present?

    # errors of author as sentence
    assert_equal 'error 1 and error 2', html_doc.css('li#dummy_author_input p.inline-errors').text
  end
end
