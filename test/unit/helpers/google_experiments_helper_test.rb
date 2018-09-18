require 'test_helper'

class GoogleExperimentsHelperTest < ActionView::TestCase

  def setup
    ThreeScale::Analytics::GoogleExperiments.expects(:enabled? => true)
  end

  def test_link_with_experiment_id
    experiment_name = 'experiment name'

    ThreeScale::Analytics::GoogleExperiments.config
        .expects(:[]).with(experiment_name).returns('some-id')

    @output_buffer += include_google_experiment('experiment name')
    assert_select 'script[src="https://www.google-analytics.com/cx/api.js?experiment=some-id"]'
  end

  protected
end
