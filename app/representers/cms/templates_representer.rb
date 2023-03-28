module CMS::TemplatesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :collection

  items extend: ->(template, *) { "#{template.type}Representer".constantize }
end
