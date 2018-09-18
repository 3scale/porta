require 'test_helper'

class CMS::Handler::MarkdownTest < ActiveSupport::TestCase
  setup do
    @handler = CMS::Handler::Markdown.new(mock)
  end

  test 'renderer should render page text' do
    html = @handler.convert <<-MARKDOWN
```ruby
class Foo
end
```
MARKDOWN
    assert_equal <<-HTML, html
<pre><code class=\"ruby\">class Foo
end
</code></pre>
HTML
  end
end
