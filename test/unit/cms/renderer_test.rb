require 'test_helper'

class CMS::RendererTest < ActiveSupport::TestCase

  test 'renderer should apply handler on a page' do
    page = mock('page', :liquid_enabled? => false, :content => '# Some text', :handler => :markdown)
    renderer = CMS::Renderer.new(nil)
    assert renderer.parse(page).is_a? CMS::Handler::Markdown
  end

end
