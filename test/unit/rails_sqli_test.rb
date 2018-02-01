# frozen_string_literal: true
require 'test_helper'

class RailsSqliTest < ActiveSupport::TestCase
  def test_action_controller_params_are_escaped
    params = ActionController::Parameters.new('system_name' => {'0' => 'foo'})
    # This should fix # https://groups.google.com/forum/#!topic/rubyonrails-security/8CVoclw-Xkk
    # No error should be raised on that and the SQL
    CMS::Section.find_by(params)
    assert_equal %(SELECT `cms_sections`.* FROM `cms_sections` WHERE `cms_sections`.`system_name` = '{\\\"0\\\"=>\\\"foo\\\"}') , CMS::Section.where(params).to_sql
  end

  def test_quoting_acton_controller_parameters
    params = ActionController::Parameters.new('system_name' => {'0' => 'foo'})
    master_account.sections.find_by_system_name(params[:system_name])
  end
end
