class TableOfContentsPortlet < CMS::Portlet::Base
  attributes :section_id, :section_id => :section # section_id attribute will have :as => :section in input
  attr_accessible :section_id
  validates_presence_of :section_id

  def self.default_template
    <<EOF
<style scoped>
div#toc {
  margin: 0 0 20px 75px;
  padding: 10px 20px 20px 20px;
  background-color: #E5EAED;
  border-radius: 5px;
  -moz-border-radius: 5px;
}
div#toc ul ul { margin:0px; }
div#toc ul.secondaryNav {padding-left: 20px;}
</style>
<div id="toc">
  <h2>Rest API Reference</h2>
  <ul class="primaryNav">
    {% for item in toc_items %}
      {{ item | toc_for }}
    {% endfor %}
  </ul>
</div>
EOF
  end

  def assigns_for_liquid
    cache(:assigns) do
      section = provider.provided_sections.find(section_id)
      { :toc_items => toc_items(section) }
    end
  end

  def liquid_options
    { :filters => CMS::ConnectorsHelper }
  end

  protected

  def attrs(node)
    {:id => node.id, :name => node.name, :path => node.path }.stringify_keys
  end

  def toc_items(section)
    begin
      nodes = []

      nodes.concat section.pages.select{ |page| page.public? && page.versions.published.exists? }.map{ |page| attrs(page) }
      nodes.concat section.children.map{ |section| { :nodes => toc_items(section), :id => section.id, :name => section.title }.stringify_keys }

      nodes.compact
    rescue
      Rails.logger.error "Exception happened when fetching getting TOC items: #{$!}"
      Rails.logger.debug "Backtrace: #{$!.backtrace.join("\n")}"

      []
    end
  end

end
