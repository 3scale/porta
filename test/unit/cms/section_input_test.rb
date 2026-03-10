# frozen_string_literal: true

require 'test_helper'

# :reek:InstanceVariableAssumption
class SectionInputTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    @root = @provider.sections.root
  end

  test 'collection returns sections in depth-first order' do
    child_a = @root.children.create!(title: 'Child A', provider: @provider)
    child_b = @root.children.create!(title: 'Child B', provider: @provider)
    grandchild = child_a.children.create!(title: 'Grandchild', provider: @provider)

    result = collection

    assert_equal [@root.id, child_a.id, grandchild.id, child_b.id], result.map(&:second)
  end

  test 'collection uses correct prefix per depth level' do
    child = @root.children.create!(title: 'Level 1', provider: @provider)
    child.children.create!(title: 'Level 2', provider: @provider)

    labels = collection.map(&:first)

    assert_equal ". Root", labels[0]
    assert_equal "|&mdash; Level 1", labels[1]
    assert_equal "|&mdash;&mdash; Level 2", labels[2]
  end

  private

  def collection
    template = stub(current_account: @provider)
    input = CMS::SectionInput.new(nil, template, nil, nil, nil, {})
    input.send(:collection)
  end
end
