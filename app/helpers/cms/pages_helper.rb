module CMS
  module PagesHelper
    def default_page_path
      @page.section.full_path
    end
  end
end
