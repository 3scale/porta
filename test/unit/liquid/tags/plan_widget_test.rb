require 'test_helper'

class Liquid::Tags::PlanWidgetTest < ActiveSupport::TestCase
  def setup
    @context = Liquid::Context.new # stub(registers: {}, stack: Queue.new)
  end

  test 'empty application' do
    template = Liquid::Template.parse('{% plan_widget %}')
    tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::PlanWidget, tag
    assert_equal "Application '' not defined for plan_widget", tag.render(@context)
  end

  test 'parses variable name' do
    ['app', ': app', 'app '].each do |params|
      template = Liquid::Template.parse("{% plan_widget #{params} %}")
      tag = template.root.nodelist.first
      assert_instance_of Liquid::Tags::PlanWidget, tag
      assert_equal 'app', tag.instance_variable_get(:@variable_name)
    end
  end

  test 'parses variable name with wizard not true' do
    ['app, wizard: 1', 'app wizard: whatever', ': app wizard: false'].each do |params|
      template = Liquid::Template.parse("{% plan_widget #{params} %}")
      tag = template.root.nodelist.first
      assert_instance_of Liquid::Tags::PlanWidget, tag
      assert_equal 'app', tag.instance_variable_get(:@variable_name)
      refute tag.instance_variable_get(:@wizard)
    end
  end

  test 'parses variable name with wizard true' do
    ['app, wizard: true', 'app wizard: true', ': app wizard: true'].each do |params|
      template = Liquid::Template.parse("{% plan_widget #{params} %}")
      tag = template.root.nodelist.first
      assert_instance_of Liquid::Tags::PlanWidget, tag
      assert_equal 'app', tag.instance_variable_get(:@variable_name)
      assert tag.instance_variable_get(:@wizard)
    end
  end

  test '#render with variable not in context' do
    template = Liquid::Template.parse('{% plan_widget not_in_context %}')
    tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::PlanWidget, tag
    assert_equal "Application 'not_in_context' not defined for plan_widget", tag.render(@context)
  end

  test '#render with variable in context' do
    template = Liquid::Template.parse('{% plan_widget myvar %}')
    tag = template.root.nodelist.first
    assert_instance_of Liquid::Tags::PlanWidget, tag
    @context['myvar'] = Liquid::Drops::Application.new('contract')

    tag.expects(:render_erb).with(@context, 'applications/applications/plan_widget', contract: @context['myvar'], wizard: false).returns('Hello world')
    assert_equal 'Hello world', tag.render(@context)
  end
end
