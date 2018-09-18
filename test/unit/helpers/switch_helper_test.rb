require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class SwitchHelperTest < ActionView::TestCase
  test 'enabled content is visible and disabled invisible if enabled' do
    output = switch(true) do |context|
      concat context.enabled  { concat 'foo' }
      concat context.disabled { concat 'bar' }
    end

    render plain: output

    assert_select 'div.enabled_block', 'foo'
    assert_select 'div.enabled_block[style=?]', 'display:none', :text => 'foo', :count => 0

    assert_select 'div.disabled_block[style=?]', 'display:none', 'bar'
  end

  test 'enabled content is invisible and disabled visible if disabled' do
    output = switch(false) do |context|
      concat context.enabled  { concat 'foo' }
      concat context.disabled { concat 'bar' }
    end

    render plain: output

    assert_select 'div.enabled_block[style=?]', 'display:none', 'foo'

    assert_select 'div.disabled_block[style=?]', 'display:none', :text => 'bar', :count => 0
    assert_select 'div.disabled_block', 'bar'
  end
end
