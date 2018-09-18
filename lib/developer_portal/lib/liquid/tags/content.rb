# -*- coding: utf-8 -*-
module Liquid
  module Tags
    class Content < Base
      tag 'content'

      desc 'Renders body of a page. Use this only inside a layout.'

      def render(context)
        content = context['content'] || context['content_for_layout']
        surround_by_comments( context,'PAGE CONTENT', nil, content)
      end
    end
  end
end
