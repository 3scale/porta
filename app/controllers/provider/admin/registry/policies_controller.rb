#frozen_string_literal: true

class Provider::Admin::Registry::PoliciesController < Provider::Admin::BaseController
  activate_menu :account, :integrate, :policies
  EXAMPLE_SCHEMA = {
      '$schema': 'http://apicast.io/policy-v1/schema#manifest#',
      name: 'Name of the policy',
      summary: 'A one-line (less than 75 characters) summary of what this policy does.',
      descriptoin: 'A complete description of what this policy does.',
      version: '0.0.1',
      configuration: {
        type: 'object',
        properties: {
          property: {
            description: 'A description of your property',
            type: 'string'
          }
        }
      }
    }.as_json.freeze

  before_action :authorize_policies

  before_action :policy, only: %i[edit update destroy]

  layout 'provider'

  def new
    @policy = PolicySchemaPresenter.new(current_account.policies.build(schema: EXAMPLE_SCHEMA.dup))
  end

  def index
    @policies = PolicySchemaPresenter::Collection.new current_account.policies
  end

  def create
    @policy = PolicySchemaPresenter.new(current_account.policies.create(policy_params))

    if @policy.persisted?
      redirect_to action: :index, notice: "Policy '#{@policy.directory}' created successfully"
    else
      render :new
    end
  end

  def edit; end

  def update
    if policy.update_attributes(policy_params)
      redirect_to action: :index
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if policy.destroy
      redirect_to action: :index
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected

  def policy_params
    params.permit(:directory, :schema)
  end

  def authorize_policies
    authorize! :manage, :policy_registry_ui
  end

  def policy
    @policy ||= PolicySchemaPresenter.new(current_account.policies.find_by_id_or_name_version!(params[:id]))
  end
end
