require 'test_helper'

class Liquid::FormsTest < ActiveSupport::TestCase
  include ThreeScale::PrivateModule(Rails.application.routes.url_helpers)

  test 'unknown form name' do
    assert_raises(Liquid::Forms::NotFoundError) do
      Liquid::Forms.find_class_by_name('math.pi')
    end
  end

  test 'correct form name' do
    assert Liquid::Forms.find_class_by_name('application.create')
  end

  test 'create application form' do
    form = get('application.create', 'application')
    application = Factory(:simple_cinstance)
    form.context['application'] = Liquid::Drops::Application.new(application)
    content = form.render('content')

    assert_match %|<form action="/admin/applications?service_id=#{application.service.id}" method="post" class="formtastic cinstance" accept-charset="UTF-8">|, content
    assert_match '<div style="margin:0;padding:0;display:inline">', content
    assert_match '<input type="hidden" name="utf8" value="&#x2713;" />', content
    assert_match '<input type="hidden" name="authenticity_token" value="', content
    assert_match '<input type="hidden" name="_method" value="post" /></div>content</form>', content
  end

  test 'password_reset form' do
    form = get('password_reset', "  ")
    content = form.render('content')
    assert_match %r{<form.*action="/admin/account/password".*</form>}, content
  end

  test 'search form' do
    form = get('search', 'search')
    presenter = stub('presenter')
    form.context['search'] = Liquid::Drops::Application.new(presenter)
    content = form.render('content')

    assert_match 'id="searchAgain"', content
    assert_match 'method="get"', content
    assert_match 'action="/search"', content
    assert_match '<input type="hidden" name="_method" value="get" />', content
  end

  test 'form with attributes' do
    form = get('search', 'search', {'id' => 'search', 'class' => 'spam-a-lot'})
    presenter = stub('presenter')
    form.context['search'] = Liquid::Drops::Application.new(presenter)
    content = form.render('content')

    assert_match 'id="search"', content
    assert_match 'spam-a-lot', content

    refute_match /id="searchAgain"/, content
  end

  test 'reply message form' do
    form = get('message.reply', 'reply')
    reply = FactoryBot.build_stubbed(:message)
    form.context['reply'] = Liquid::Drops::Message.new(reply)
    content = form.render('content')

    assert_match 'id="message-form"', content
    assert_match 'method="post"', content
    assert_match '/admin/messages/received', content
    assert_match 'class="formtastic message reply"', content
  end

  test 'create message form' do
    form = get('message.create', 'message')
    message = FactoryBot.build_stubbed(:message)
    form.context['message'] = Liquid::Drops::Message.new(message)
    content = form.render('content')

    assert_match 'id="message-form"', content
    assert_match 'method="post"', content
    assert_match '/admin/messages/sent', content
    assert_match 'class="formtastic message"', content
  end

  test 'change plan form' do
    form = get('plan.change')
    content = form.render('content')
    assert_match '/buyer/account_contract', content
  end

  private

  def get(form, name = 'object', html_attributes={})
    Liquid::Forms.find_class_by_name(form).new(context, name, html_attributes)
  end

  def controller
    controller = ApplicationController.new
    controller.stubs(:session).returns(ActionDispatch::Request.new({}).session)
    controller
  end

  def registers
    { controller: controller }
  end

  def context
    context = {}
    context.stubs(:registers).returns(registers)
    context
  end

end
