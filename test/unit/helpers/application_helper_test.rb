require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  attr_accessor :current_user
  delegate :can?, to: :ability

  def test_link_to_export_widget_for
    self.current_user = FactoryBot.build_stubbed(:member, account: account)
    link = link_to_export_widget_for('Accounts')
    assert_nil link

    self.current_user = FactoryBot.build_stubbed(:admin, account: account)
    link = link_to_export_widget_for('Accounts')
    assert_match /a/, link
  end

  def test_css_class
    assert_equal 'some class', css_class('some', 'class')

    assert_equal 'yes maybe', css_class('yes' => true, 'no' => false, maybe: 'yeah')

    assert_equal 'one two three', css_class('one', ['two'], three: true)
  end

  private

  def ability
    Ability.new(current_user)
  end

  def account
    @account ||= FactoryBot.build_stubbed(:simple_provider)
  end
end
