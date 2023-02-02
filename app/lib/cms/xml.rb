# frozen_string_literal: true

module CMS::XML
  TAG_NAMES = {
    'cms-page': 'page',
    'cms-builtin-page': 'builtin_page',
    'cms-partial': 'partial',
    'cms-builtin-partial': 'builtin_partial',
    'cms-layout': 'layout',
    'cms-file': 'file',
    'cms-section': 'section',
    'cms-builtin-section': 'builtin_section'
  }.freeze

  CLASS_TAG = ->(c) { TAG_NAMES[c.name.parameterize.to_sym] }
end
