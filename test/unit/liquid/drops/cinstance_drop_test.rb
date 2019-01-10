require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Liquid::Drops::CinstanceDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @plan = FactoryBot.create(:application_plan)
    @app = FactoryBot.create(:cinstance, :plan => @plan)
  end

  test "returns the associated plan" do
    drop = Liquid::Drops::Application.new(@app)
    assert drop.plan.is_a?(Liquid::Drops::Plan)
  end
end
