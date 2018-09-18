require 'test_helper'

class Liquid::Tags::DebugTest < ActiveSupport::TestCase

  def setup
    @debug = Liquid::Tags::Debug.parse('debug', ':help', [], {})
  end

  test "render help" do
    context = mock('context')
    @debug.expects(:render_help).with(context)

    @debug.render(context)
  end

  test "retrieve assigns from context" do
    context = mock('context', :environments => [{:variable => 'value'}, {:scoped => 'val'}])
    assert_equal({:variable => 'value', :scoped => 'val'}, @debug.assigns(context))
  end

  test "render table with variables" do
    context = mock('context')

    @debug.expects(:assigns).with(context).returns({})
    @debug.expects(:help).with({}).returns([])
    @debug.expects(:html_comment)

    @debug.render_help(context)
  end

  test "render proper list of assigns" do
    assigns = {
      :current_account => Liquid::Drops::Account.new('account-dummy'),
      :text => "Some string",
      :apps => Liquid::Drops::Application.wrap(['app-dummy'])
    }.stringify_keys

    help_text = @debug.help(assigns)

    assert_match /current_account\s+=>\s+Account/, help_text[0]
    assert_match /text\s+=>\s+String/, help_text[1]
    assert_match /apps\s+=>\s+Collection +\(Application\)/, help_text[2]
  end

end
