module Liquid
  module Tags
    class ThemeStylesheet < Base
      nodoc!

      # marked for deletion

      def render(context)
        if template = context.registers[:site_account].templates.find_by_name('theme_css')
          %(<link rel="stylesheet" href="/stylesheets/theme.css?#{template.updated_at.to_i}" media="screen" type="text/css" />)
        end
      end
    end
  end
end
