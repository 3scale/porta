module ExternalRssFeedPortletRepresenter
  include ThreeScale::JSONRepresenter
  include CMS::PortletRepresenter

  property :url_feed
end
