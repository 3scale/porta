module LineItemsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :line_items

  items extend: LineItemRepresenter
end
