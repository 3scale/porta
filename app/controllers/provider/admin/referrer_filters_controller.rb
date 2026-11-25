# frozen_string_literal: true

class Provider::Admin::ReferrerFiltersController < Provider::Admin::BaseController
  before_action { head :not_acceptable unless request.format.js? }
  before_action :find_cinstance

  def create
    @referrer_filter = @cinstance.referrer_filters.add(params[:referrer_filter])

    if @referrer_filter.persisted?
      render :refresh_widget
    else
      @error = @referrer_filter.errors.full_messages.to_sentence
      render :error
    end
  end

  def destroy
    @referrer_filter = @cinstance.referrer_filters.find params[:id]
    @referrer_filter.destroy

    render :refresh_widget
  end

  private

  def find_cinstance
    @cinstance = current_account.provided_cinstances.by_service(@service).find(params[:application_id])
  end
end
