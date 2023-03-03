module CMS::PartialRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource -> (*) { self.class.data_tag }

  property :id
  property :created_at
  property :updated_at
  property :system_name

  with_options(if: ->(options) { !options[:short] }) do |p|
    p.property :draft, render_nil: true
    p.property :published, render_nil: true
  end
end
