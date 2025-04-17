require 'test_helper'

class CMS::PortletTest < ActiveSupport::TestCase

  test 'convertion to portlet' do
    partial = CMS::Partial.new # loading this class will create attribute methods for options
    portlet = FactoryBot.create(:cms_portlet, :portlet_type => 'ExternalRssFeedPortlet')
    portlet = CMS::Portlet.find(portlet.id)

    feed = portlet.to_portlet

    assert_instance_of(ExternalRssFeedPortlet, feed)

    feed.url_feed = 'some-url'

    assert feed.url_feed
    assert feed.valid?
  end

  test 'human name' do
    assert_equal 'External RSS Feed', ExternalRssFeedPortlet.model_name.human
    assert_equal 'Table of Contents', TableOfContentsPortlet.model_name.human
    assert_equal 'Latest Forum Posts', LatestForumPostsPortlet.model_name.human
  end

  class CustomPortlet < CMS::Portlet::Base
    attributes :fancyness
    attr_accessible :fancyness
    validates_presence_of :fancyness
  end

  test 'custom portlet' do
    custom = CustomPortlet.new

    custom.attributes = {:fancyness => 42}

    refute custom.valid?

    assert_equal 42, custom.fancyness
    refute custom.valid?
  end

end
