require 'test_helper'

class Liquid::Drops::UrlDropTest < ActiveSupport::TestCase

  def setup
    @drop = Liquid::Drops::Url.new('http://example.com/admin/messages')
  end

  test '#current?' do
    stub_context(stub(path: '/admin/messages'))
    assert @drop.current?
  end

  test '#current? without :request' do
    # without
    stub_context(nil)
    refute @drop.current?
  end

  test '#current? in called in different path' do
    stub_context(stub(path: '/some/other/path'))
    refute @drop.current?
  end

  test '#current_or_subpath? in current path' do
    stub_context(stub(path: '/admin/messages'))
    assert @drop.current_or_subpath?
  end

  test '#current_or_subpath? called in deeper path' do
    stub_context(stub(path: '/admin/messages/12/edit'))
    assert @drop.current_or_subpath?
  end

  test '#current_or_subpath? called in parent path' do
    stub_context(stub(path: '/admin'))
    refute @drop.current_or_subpath?
  end

  test '#current_or_subpath? called in similar path' do
    stub_context(stub(path: '/messages'))
    refute @drop.current_or_subpath?
  end

  test '#current_or_subpath? called in similar path 2' do
    drop = Liquid::Drops::Url.new('http://example.com/messages')
    stub_context(stub(path: 'admin/messages'), drop)
    refute drop.current_or_subpath?
  end

  test '#current_or_subpath? without :request' do
    stub_context(nil)
    refute @drop.current_or_subpath?
  end

  test '#current_or_subpath? called in different path' do
    stub_context(stub(path: '/some/other/path'))
    refute @drop.current_or_subpath?
  end

  private

  def stub_context(request, drop = @drop)
    drop.stubs(context: stub(registers: { request: request }))
  end

end
