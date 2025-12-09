require 'test_helper'

class Liquid::Tags::FormTest < ActiveSupport::TestCase

  def setup
    @context = Liquid::Context.new # stub(registers: {}, stack: Queue.new)
    @context.registers[:controller] = stub_everything
  end

  test "non-existent form application" do
    template = Liquid::Template.parse("{% form 'application' %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    assert_equal "<!-- form_tag error: Liquid error: Unknown form 'application' -->",  @tag.render(@context)
  end

  test "missing not supplied" do
    template = Liquid::Template.parse("{% form 'application.create' %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    assert_match 'no object specified', @tag.render(@context)
  end

  test "variable not assigned" do
    template = Liquid::Template.parse("{% form 'application.create', not_here %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    assert_match "variable 'not_here' is missing", @tag.render(@context)
  end

  test "application.create form" do
    @context['app'] = Liquid::Drops::Application.new(FactoryBot.create(:application))
    template = Liquid::Template.parse("{% form 'application.create', app %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    assert_match %r{<form.*>.*</form>}, @tag.render(@context)
  end

  test "signup form basics" do
    account = Liquid::Drops::Account.new(FactoryBot.create(:simple_buyer))
    @context['my_account'] = account
    @context['site_account'] = account
    template = Liquid::Template.parse("{% form 'signup', my_account %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    assert_match %r{<form.*id="signup_form".*>.*</form>}, @tag.render(@context)
  end


  test "signup form with plan_ids param" do
    account = Liquid::Drops::Account.new(FactoryBot.create(:simple_buyer))
    @context['my_account'] = account
    @context['site_account'] = account
    @context.registers[:request] = stub(params: { plan_ids: [ 1,2,42 ]})

    template = Liquid::Template.parse("{% form 'signup', my_account %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    html = @tag.render(@context)
    hidden_inputs = Nokogiri.parse(html).css('form input[name="plan_ids[]"]')

    assert_equal 3, hidden_inputs.size
    assert_equal [ 1,2,42 ], hidden_inputs.map { |i| i.attr('value').to_i }.sort
  end

  test "user.personal_details" do
    @context['user'] = Liquid::Drops::User.new(FactoryBot.create(:active_user))
    template = Liquid::Template.parse("{% form 'user.personal_details', user %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    assert_match %r{<form.*id="edit_personal_details".*>.*</form>}, @tag.render(@context)
    assert_match %r{<form.*class=.*personal_details.*>.*</form>}, @tag.render(@context)
    assert_match %r{<input.*type="hidden".*name="origin".*/>}, @tag.render(@context)

    @context.registers[:controller] = stub_everything(params: {origin: 'foo'})
    template = Liquid::Template.parse("{% form 'user.personal_details', user %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    assert_match %r{<form.*id="edit_personal_details".*>.*</form>}, @tag.render(@context)
    assert_match %r{<form.*class=.*personal_details.*>.*</form>}, @tag.render(@context)
    assert_match %r{<input.*type="hidden".*name="origin".*value="foo".*/>}, @tag.render(@context)
  end

  test "user.edit" do
    user = FactoryBot.create(:active_user)
    @context['user'] = Liquid::Drops::User.new(user)
    template = Liquid::Template.parse("{% form 'user.edit', user %}CONTENT{% endform %}")
    @tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::Form, @tag
    assert_match %r{<form.*id="edit_user_#{user.id}".*>.*</form>}, @tag.render(@context)
    assert_match %r{<form.*class=.*edit-user-form.*>.*</form>}, @tag.render(@context)
  end
end
