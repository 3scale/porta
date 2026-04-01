# frozen_string_literal: true

module Provider
  module Admin
    module User
      class AccessTokensController < BaseController
        authorize_resource

        activate_menu :account, :personal, :tokens
        before_action :authorize_access_tokens
        before_action :disable_client_cache
        before_action :load_access_token, only: %i[edit update destroy]

        helper_method :access_tokens, :service_tokens

        def index; end

        def new
          @presenter = AccessTokensNewPresenter.new(current_account)
          @access_token = access_tokens.build
        end

        def edit; end

        def create
          @access_token = access_tokens.build(access_token_params)

          if @access_token.save
            flash.now[:success] = t('.success')
            render :show, locals: { token: @access_token }
          else
            @presenter = AccessTokensNewPresenter.new(current_account)
            render :new
          end
        end

        def update
          if @access_token.update(access_token_params)
            redirect_to provider_admin_user_access_tokens_path, success: t('.success')
          else
            render :edit
          end
        end

        def destroy
          if @access_token.destroy
            redirect_to provider_admin_user_access_tokens_path, success: t('.success')
          else
            redirect_to provider_admin_user_access_tokens_path, danger: t('.error')
          end
        end

        private

        def authorize_access_tokens
          authorize! :manage, :access_tokens, current_user
        end

        def access_tokens
          @access_tokens ||= current_user.access_tokens
        end

        def service_tokens
          @service_tokens ||= current_user.decorate.accessible_services_with_token
        end

        def load_access_token
          @access_token = access_tokens.find(params[:id])
        end

        def access_token_params
          params.require(:access_token).permit(:name, :permission, :expires_at, scopes: [])
        end
      end
    end
  end
end
