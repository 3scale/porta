module CategorizableInterfaceTest

  def test_categorizable_interface
    assert_not_nil event_class.category
    assert Symbol, event_class.category
  end

  private

  def event_class
    self.class.to_s.sub(/Test$/, '').constantize
  end
end
