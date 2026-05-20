# frozen_string_literal: true

class Admin::FieldsDefinitionsController < Sites::BaseController
  respond_to :html
  activate_menu :audience, :accounts, :fields_definitions

  before_action :set_fields_definition_params, only: %i[new create update]
  before_action :validate_target, only: [:new]

  def index
    @possible_targets = available_targets

    respond_with(fields_definitions)
  end

  def new
    target = fields_definition_params[:target]

    @fields_definition = fields_definitions.build(target: target)
    target_class = @fields_definition.target_class

    @optional_fields = target_class.builtin_fields - existing_fields_names_by_target(target)

    @required_fields = target_class.required_fields

    @optional_fields.unshift "[new field]"

    respond_with(@fields_definition)
  end

  def edit
    @optional_fields = fields_definition.target_class.builtin_fields
    @required_fields = fields_definition.target_class.required_fields

    respond_with(fields_definition)
  end

  def create
    @fields_definition = fields_definitions.build(fields_definition_params)

    if @fields_definition.save
      flash[:success] = t('.success')

    elsif @fields_definition.errors[:target].empty?
      @optional_fields = @fields_definition.target.classify.constantize.builtin_fields -
          current_account.reload.fields_definitions.by_target(@fields_definition.target).map(&:name)
      @required_fields = @fields_definition.target_class.required_fields
      @optional_fields.unshift "[new field]"
    end

    respond_with(@fields_definition, location: admin_fields_definitions_path)
  end

  def update
    @required_fields = []
    @required_fields = fields_definition.target_class.required_fields if fields_definition.update(fields_definition_params)

    respond_with(fields_definition, location: admin_fields_definitions_path)
  end

  def destroy
    fields_definition.destroy
    respond_with(fields_definition, location: admin_fields_definitions_path)
  end

  def sort
    fields = current_account.fields_definitions.find(sort_params).index_by(&:id)

    sort_params.each_with_index do |field_id, index|
      fields.fetch(field_id.to_i).update_attribute(:pos, index + 1)
    end

    head :no_content
  end

  private

  attr_reader :fields_definition_params

  def sort_params
    @sort_params ||= params.permit(fields_definition: [])[:fields_definition] || []
  end

  def fields_definitions
    @fields_definitions ||= current_account.fields_definitions
  end

  def fields_definition
    @fields_definition ||= fields_definitions.find(params[:id])
  end

  def available_targets
    @available_targets ||= FieldsDefinition.targets
  end

  def existing_fields_names_by_target(target)
    current_account.fields_definitions.by_target(target).map(&:name)
  end

  def set_fields_definition_params
    fd_params = params.fetch(:fields_definition)
    if fd_params.respond_to? :permit
      @fields_definition_params = fd_params.permit(:target, :name, :label, :required, :hidden, :read_only, :choices_for_views)
    else
      render_error "invalid fields definition", status: :bad_request unless fd_params.is_a?(Hash)
    end
  end

  def validate_target
    render_error "invalid fields definition target", status: :bad_request unless available_targets.include?(fields_definition_params[:target])
  end
end
