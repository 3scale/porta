# frozen_string_literal: true

module DeveloperPortal
  class SignupController < DeveloperPortal::BaseController
    include ThreeScale::SpamProtection::Integration::Controller

    skip_before_action :login_required
    before_action :redirect_if_logged_in

    before_action :find_provider
    before_action :deny_if_signup_disabled
    before_action :find_plans, :except => :success
    before_action :set_strategy, :only => %i[show create]
    skip_before_action :finish_signup_for_paid_plan

    self.builtin_template_scope = 'signup'

    liquify prefix: 'signup'

    def show
      @buyer = @provider.buyers.build
      @user = @buyer.users.build_with_fields :role => :admin
      @strategy.on_new_user(@user, session)

      assign_drops(signup_drops)

      respond_to do |format|
        format.html
      end
    end

    def create
      account_params = (params[:account] || {}) .dup
      user_params    = account_params.try(:delete, :user) || {}

      if signup_user!(account_params, user_params)
        if @user.can_login?
          self.current_user = @user
          create_user_session!
          flash[:notice] = "Signed up successfully"
          redirect_back_or_default(@strategy.redirect_to_on_successful_login)
        else
          redirect_to success_signup_path
        end
      else
        assign_drops(signup_drops)
        render :show
      end
    rescue ActiveRecord::RecordInvalid
      # HACK: handles concurrency issues - it may happen that
      # @user.valid? but @user.save! fails because the same user was
      # already inserted before (double-click on signup button)
      #
      # https://3scale.airbrake.io/errors/25132810
      #

      if Rails.env.development? || Rails.env.test?
        raise
      else
        render :show
      end
    end

    def success; end

    private

    def authentication_provider
      site_account.authentication_providers
        .find_by(system_name: session[:authentication_provider])
    end

    def signup_user!(account_params, user_params)
      Account.transaction do
        SignupService.create(signup_service_params(account_params, user_params)) do |signup_result|
          @signup_result = signup_result
          @user  = signup_result.user
          @buyer = signup_result.account
          break unless spam_check(@buyer)
        end
      end

      @signup_result.persisted?
    end

    def signup_service_params(account_params, user_params)
      { provider:       @provider,
        plans:          @plans,
        session:        session,
        account_params: account_params,
        user_params:    user_params,
        authentication_provider: authentication_provider
      }
    end

    def redirect_if_logged_in
      redirect_to admin_dashboard_path if logged_in?
    end

    def signup_drops
      drops = { user: Liquid::Drops::User.new(@user),
        account: Liquid::Drops::Account.new(@buyer),
        plans: Liquid::Drops::Collection.new(@plans) }

      case @strategy
      when Authentication::Strategy::Cas
        drops[:cas] = Liquid::Drops::AuthenticationStrategy::Cas.new(@strategy)
      end

      drops
    end

    def set_strategy
      @strategy = Authentication::Strategy.build(site_account)
    end

    def find_plans
      # :plans is kept for legacy reasons - can be removed one made sure
      # that noone is using it
      plan_ids = Array(params[:plan_ids].presence || params[:plans])

      @plans = @provider.provided_plans.published.find(plan_ids)
    end

    def find_provider
      @provider = site_account
    end

    def deny_if_signup_disabled
      render :plain => 'Signup disabled', :status => :forbidden unless @provider.signup_enabled?
    end

    def convert_legacy_params
      %i[account_plan service_plan application_plan].each do |type|
        params[:plans] ||= []
        params[:plans] << params[type] if params[type].present?
      end
    end
  end
end
