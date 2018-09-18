module XPathOriginalTitle

  def link(locator)
    locator = locator.to_s
    link = descendant(:a)[attr_reader(:href)]
    super + link[attr_reader(:'original-title').contains(locator)]
  end
end

XPath::HTML.prepend(XPathOriginalTitle)
