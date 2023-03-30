# frozen_string_literal: true

class CMS::TypeMap

  class << self
    CLASS_TYPES = {
      page: CMS::Page,
      builtin_page: CMS::Builtin::Page,
      builtin_static_page: CMS::Builtin::StaticPage,
      partial: CMS::Partial,
      builtin_partial: CMS::Builtin::Partial,
      layout: CMS::Layout,
    }.freeze

    def cms_type(cms_class)
      CLASS_TYPES.rassoc(cms_class)[0]
    end

    def cms_class(cms_type)
      CLASS_TYPES[cms_type.to_sym]
    end
  end
end
