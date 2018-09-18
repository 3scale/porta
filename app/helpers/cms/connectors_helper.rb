module CMS
  module ConnectorsHelper
    def toc_for(item)
      buff = ""
      case
      when nodes = item['nodes']
        buff << "<li id=\"section-#{item['id']}\">"
        buff << "<a href='#'><span>#{item['name']}</span></a>"
        buff << "<ul class='secondaryNav'>"
        nodes.each do | node |
          buff << toc_for(node)
        end
        buff << "</ul></li>"
      else
        buff << "<li id=\"page-#{item['id']}\">#{link_to(truncate(item['name']), item['path'], {:title=>item['name']})}</li>"
      end
      buff
    end
  end
end
