require 'test_helper'

class GoogleExperimentsControllerTest < ActionController::TestCase

  def setup
    ThreeScale::Analytics::GoogleExperiments.stubs(:enabled?).returns(true)
  end

  def test_report
    get :report
    assert_response :success

    assert response.body

    assert_body('status' => 'success', 'experiments' => {})
  end

  def test_google_experiment_failure
    cookies[:__utmx] = '67508621.LZh8g5E-TCiGSa118bhKfA$0:1'
    ThreeScale::Analytics::GoogleExperiments.stubs(:fetch_info).raises(StandardError)
    ::System::ErrorReporting.expects(:report_error).with(instance_of(StandardError)).once

    get :report
    assert_response :success

    assert_body('status' => 'success', 'experiments' => {})
  end

  def test_without_google_experiment
    get :report
    assert_response :success

    assert_body('status' => 'success', 'experiments' => {})
  end

  private

  def assert_body(expected, actual = JSON.parse(response.body))
    assert_equal expected, actual
  end
end
