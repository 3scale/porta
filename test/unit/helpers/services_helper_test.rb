require 'test_helper'

class ServicesHelperTest < ActionView::TestCase
  def test_show_mappings?
    @service = Service.new(deployment_option: nil)
    assert show_mappings?

    @service.deployment_option = 'hosted'
    assert show_mappings?

    @service.deployment_option = 'plugin_java'
    refute show_mappings?
  end
end
