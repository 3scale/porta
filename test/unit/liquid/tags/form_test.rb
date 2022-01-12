# frozen_string_literal: true

require 'test_helper'

class Liquid::Tags::FormTest < ActiveSupport::TestCase

  def setup
    @context = Liquid::Context.new # stub(registers: {}, stack: Queue.new)
    @context.registers[:controller] = stub_everything
  end

  test "non-existent form application" do
    @tag = create_form("'application'", ["CONTENT", '{% endform %}'])
    assert_equal "<!-- form_tag error: Liquid error: Unknown form 'application' -->",  @tag.render(@context)
  end

  test "missing not supplied" do
    @tag = create_form("'application.create'", ["CONTENT", '{% endform %}'])
    assert_match 'no object specified', @tag.render(@context)
  end

  test "variable not assigned" do
    @tag = create_form("'application.create', not_here", ["CONTENT", '{% endform %}'])
    assert_match "variable 'not_here' is missing", @tag.render(@context)
  end

  test "application.create form" do
    @context['app'] = Liquid::Drops::Application.new(FactoryBot.create(:application))
    @tag = create_form("'application.create', app", ["CONTENT", '{% endform %}'])
    assert_match %r{<form.*>.*</form>}, @tag.render(@context)
  end

  test "signup form basics" do
    account = Liquid::Drops::Account.new(FactoryBot.create(:simple_buyer))
    @context['my_account'] = account
    @context['site_account'] = account
    @tag = create_form("'signup', my_account", ["CONTENT", '{% endform %}'])
    assert_match %r{<form.*id="signup_form".*>.*</form>}, @tag.render(@context)
  end

  test "signup form with plan_ids param" do
    account = Liquid::Drops::Account.new(FactoryBot.create(:simple_buyer))
    @context['my_account'] = account
    @context['site_account'] = account
    @context.registers[:request] = stub(params: { plan_ids: [1,2,42]})

    @tag = create_form("'signup', my_account", ["CONTENT", '{% endform %}'])
    html = @tag.render(@context)
    hidden_inputs = Nokogiri.parse(html).css('form input[name="plan_ids[]"]')

    assert_equal 3, hidden_inputs.size
    assert_equal [1,2,42], hidden_inputs.map { |i| i.attr('value').to_i }.sort
  end

  test "user.personal_details" do
    @context['user'] = Liquid::Drops::User.new(FactoryBot.create(:active_user))
    @tag = create_form("'user.personal_details', user", ["CONTENT", '{% endform %}'])
    assert_match %r{<form.*id="edit_personal_details".*>.*</form>}, @tag.render(@context)
    assert_match %r{<form.*class=.*personal_details.*>.*</form>}, @tag.render(@context)
    assert_match %r{<input.*type="hidden".*name="origin".*/>}, @tag.render(@context)

    @context.registers[:controller] = stub_everything(params: {origin: 'foo'})
    @tag = create_form("'user.personal_details', user", ["CONTENT", '{% endform %}'])
    assert_match %r{<form.*id="edit_personal_details".*>.*</form>}, @tag.render(@context)
    assert_match %r{<form.*class=.*personal_details.*>.*</form>}, @tag.render(@context)
    assert_match %r{<input.*type="hidden".*name="origin".*value="foo".*/>}, @tag.render(@context)
  end

  test "user.edit" do
    user = FactoryBot.create(:active_user)
    @context['user'] = Liquid::Drops::User.new(user)
    @tag = create_form("'user.edit', user", ["CONTENT", '{% endform %}'])

    assert_match %r{<form.*id="edit_user_#{user.id}".*>.*</form>}, @tag.render(@context)
    assert_match %r{<form.*class=.*edit-user-form.*>.*</form>}, @tag.render(@context)
  end

  private

  def create_form(markup, tokens = [], options = {})
    tokenizer = Liquid::Tokenizer.new(tokens.join)
    parse_context = Liquid::ParseContext.new
    Liquid::Tags::Form.parse('form', markup, tokenizer, parse_context)
  end
end
