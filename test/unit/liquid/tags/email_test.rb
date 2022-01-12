# frozen_string_literal: true

require 'test_helper'

class Liquid::Tags::EmailTest < ActiveSupport::TestCase
  def setup
    @subject = "{% subject = 'my fancy subject' %}"
    @header = "{% header 'MyHeader' = 'Value' %}"
    @bcc = "{% bcc 'fancy <fancy@example.com>' 'another@mail.com' 'and@more.com' %}"
    @cc = "{% cc 'just@me.com' %}"
    @reply_to = "{% reply_to 'over@lord.com' %}"
    @from = "{% from 'secret@mail.com' %}"
    @end = "{% endemail %}"
    @email = create_email('', [@subject, @header, @bcc, @cc, @reply_to, @from, @end])
  end

  test "email without liquid tags" do
    email = create_email('some params', ["some content", @end])
    context = stub(:registers => {})
    assert_equal '', email.render(context)
  end

  test "render empty content" do
    context = stub(:registers => {})
    assert_equal '', @email.render(context)
  end

  test "do_not_send" do
    context = stub(:registers => {})
    create_email('', ['{% do_not_send %}', @end])
    assert_equal '', @email.render(context)
  end

  test "assign all tags to message" do
    message = stub_everything('message')
    headers = stub_everything('headers')

    registers = {:message => message}

    message.expects(:subject=).with('my fancy subject')
    message.expects(:headers).returns(headers).at_least_once

    headers.expects(:[]=).with('MyHeader', 'Value')
    headers.expects(:[]=).with('bcc', ['fancy <fancy@example.com>', 'another@mail.com', 'and@more.com'])
    headers.expects(:[]=).with('cc', ['just@me.com'])
    headers.expects(:[]=).with('from', 'secret@mail.com')
    headers.expects(:[]=).with('reply-to', 'over@lord.com')

    context = stub(:registers => registers)

    @email.render(context)
  end

  test "assign all tags to mailer" do
    mail = stub_everything('mail')
    registers = {:mail => mail}

    mail.expects(:[]=).with(:subject, 'my fancy subject')
    mail.expects(:[]=).with(:bcc, ['fancy <fancy@example.com>', 'another@mail.com', 'and@more.com'])
    mail.expects(:[]=).with(:cc, ['just@me.com'])
    mail.expects(:[]=).with(:from, 'secret@mail.com')
    mail.expects(:[]=).with(:reply_to, 'over@lord.com')
    mail.expects(:headers).with('MyHeader' => 'Value')

    context = stub(:registers => registers)

    @email.render(context)
  end

  test "assign do_not_send header to mailer" do
    mail = create_email('', ['{% do_not_send %}', @end])
    mail.expects(:headers).with(::Message::DO_NOT_SEND_HEADER => true)

    context = stub(:registers => {mail: mail})
    mail.render(context)
  end

  private

  def create_email(markup, tokens = [], options = {})
    tokenizer = Liquid::Tokenizer.new(tokens.join)
    parse_context = Liquid::ParseContext.new(options)
    Liquid::Tags::Email.parse('email', '', tokenizer, parse_context)
  end
end
