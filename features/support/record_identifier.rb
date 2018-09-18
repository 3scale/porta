module DomID
  def dom_id(object)
    ActionView::RecordIdentifier.dom_id(object)
  end
end

World(DomID)
