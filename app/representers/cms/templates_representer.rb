module CMS::TemplatesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :templates

  items extend: ->(template, *) { "#{template.type}Representer".constantize }
end
