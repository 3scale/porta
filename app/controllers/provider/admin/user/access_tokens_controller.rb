# frozen_string_literal: true

module Provider
  module Admin
    module User
      class AccessTokensController < BaseController
        inherit_resources
        defaults route_prefix: 'provider_admin_user', resource_class: AccessToken
        actions :index, :new, :create, :edit, :update, :destroy

        authorize_resource
        activate_menu :account, :personal, :tokens
        before_action :authorize_access_tokens
        before_action :disable_client_cache

        def new
          @presenter = AccessTokensNewPresenter.new(current_account)
        end

        def create
          @presenter = AccessTokensNewPresenter.new(current_account)
          create! do |success, _failure|
            success.html do
              flash[:token] = @access_token.id
              redirect_to collection_url, success: t('.success')
            end
          end
        end

        def destroy
          destroy! do |success|
            success.html do
              flash[:success] = t('.success')
              super
            end
          end
        end

        def index
          index!
          @last_access_key = flash[:token]
        end

        def update
          update! do |success, _failure|
            success.html do
              redirect_to collection_url, success: t('.success')
            end
          end
        end

        private

        def authorize_access_tokens
          authorize! :manage, :access_tokens, current_user
        end

        def begin_of_association_chain
          current_user
        end
      end
    end
  end
end
