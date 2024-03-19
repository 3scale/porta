module CMS::TemplatesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :collection

  items extend: ->(options) { "#{options[:input].type}Representer".constantize }
end
