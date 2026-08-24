# frozen_string_literal: true

require 'test_helper'

class Apicast::PcreEscaperTest < ActiveSupport::TestCase
  test 'escapes dots in path' do
    assert_equal '/foo\\.bar', Apicast::PcreEscaper.escape('/foo.bar')
  end

  test 'escapes asterisks in path' do
    assert_equal '/foo\\*', Apicast::PcreEscaper.escape('/foo*')
  end

  test 'escapes parentheses in path' do
    assert_equal '/foo\\(bar\\)', Apicast::PcreEscaper.escape('/foo(bar)')
  end

  test 'escapes plus in path' do
    assert_equal '/foo\\+bar', Apicast::PcreEscaper.escape('/foo+bar')
  end

  test 'escapes multiple metacharacters' do
    assert_equal '/service1\\.svc/data\\(\\*\\)', Apicast::PcreEscaper.escape('/service1.svc/data(*)')
  end

  test 'preserves template variables' do
    assert_equal '/foo/{bar}\\.json', Apicast::PcreEscaper.escape('/foo/{bar}.json')
  end

  test 'preserves trailing dollar anchor' do
    assert_equal '/foo$', Apicast::PcreEscaper.escape('/foo$')
  end

  test 'preserves trailing dollar anchor with query string' do
    assert_equal '/foo$?bar=baz', Apicast::PcreEscaper.escape('/foo$?bar=baz')
  end

  test 'preserves percent-encoded sequences in path' do
    assert_equal '/foo%20bar', Apicast::PcreEscaper.escape('/foo%20bar')
  end

  test 'escapes dollar in query string' do
    assert_equal '/foo?price=\\$10', Apicast::PcreEscaper.escape('/foo?price=$10')
  end

  test 'escapes question mark in query string' do
    assert_equal '/foo?a=b\\?c', Apicast::PcreEscaper.escape('/foo?a=b?c')
  end

  test 'escapes brackets in query string' do
    assert_equal '/foo?bar=\\[val\\]', Apicast::PcreEscaper.escape('/foo?bar=[val]')
  end

  test 'preserves template variables in query string' do
    assert_equal '/foo?bar={baz}', Apicast::PcreEscaper.escape('/foo?bar={baz}')
  end

  test 'slash-only pattern is unchanged' do
    assert_equal '/', Apicast::PcreEscaper.escape('/')
  end

  test 'blank pattern is returned as-is' do
    assert_equal '', Apicast::PcreEscaper.escape('')
    assert_nil Apicast::PcreEscaper.escape(nil)
  end

  # $ is not escaped in path because PatternParser only allows it at end-of-path
  # where it serves as an intentional APICast anchor. Mid-path $ (e.g. /micro$oft)
  # is rejected by PatternParser validation in ProxyRule.
  test 'does not escape dollar in path since validation only allows it at end' do
    assert_equal '/foo$', Apicast::PcreEscaper.escape('/foo$')
    assert_equal '/foo/bar$', Apicast::PcreEscaper.escape('/foo/bar$')
  end

  test 'escapes all metacharacters in a segment' do
    assert_equal '/\\(\\.\\*\\)', Apicast::PcreEscaper.escape('/(.*)')
  end

  test 'complex real-world pattern with dots and colons' do
    input    = '/business-central/rest/runtime/com.redhat.demos:3.0/start'
    expected = '/business-central/rest/runtime/com\\.redhat\\.demos:3\\.0/start'
    assert_equal expected, Apicast::PcreEscaper.escape(input)
  end

  test 'path with dots and query string with brackets and dollar' do
    input    = '/api.v2/search?filter=[$10]'
    expected = '/api\\.v2/search?filter=\\[\\$10\\]'
    assert_equal expected, Apicast::PcreEscaper.escape(input)
  end
end
