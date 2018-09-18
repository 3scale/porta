require 'liquid'

module Liquid

  # Preload and convert Markdown -> HTML
  # for all files Liquid snippets from doc/liquid/snippets
  #
  ThreeScaleSnippets = begin
                         docs =Rails.root.join('doc','liquid','snippets').children.map do |snippet|
                           name = snippet.basename('.md').to_s
                           markdown = snippet.read
                           html = HTML::Pipeline::MarkdownFilter.call(markdown).html_safe
                           [ name, html ]
                         end

                         Hash[docs].freeze
                       end
end
