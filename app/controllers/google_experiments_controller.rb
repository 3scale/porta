class GoogleExperimentsController < ApplicationController

  before_action :cors

  skip_before_action :verify_authenticity_token

  def report
    if enabled?
      render json: { status: 'success', experiments: google_experiments }
    else
      render json: { status: 'disabled' }
    end
  end

  protected

  delegate :enabled?, to: ThreeScale::Analytics::GoogleExperiments
end
