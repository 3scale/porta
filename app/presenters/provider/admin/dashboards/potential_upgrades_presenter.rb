# frozen_string_literal: true

class Provider::Admin::Dashboards::PotentialUpgradesPresenter
  include ::Draper::ViewHelpers

  attr_reader :set_up_correctly, :upgrades

  ID = 'potential-upgrades-widget'
  NAME = :potential_upgrades

  def initialize(data)
    @set_up_correctly = data.delete(:set_up_correctly)
    @upgrades = data.delete(:upgrades)
  end

  def render
    h.render "provider/admin/dashboards/widgets/#{NAME}", widget: self
  end

  def id
    ID
  end
end
