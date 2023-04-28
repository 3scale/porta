#frozen_string_literal: true

class Admin::Api::FieldsDefinitionsController < Admin::Api::BaseController

  # we need to include position, because FieldsDefinition is creating it as an alias
  wrap_parameters include: FieldsDefinition.attribute_names << 'position'
  representer FieldsDefinition

  # Fields Definitions List
  # GET /admin/api/fields_definitions.json
  def index
    respond_with(fields_definitions)
  end

  # Fields Definition Create
  # POST /admin/api/fields_definitions.json
  def create
    field_def = fields_definitions.build(create_params)

    field_def.save

    respond_with(field_def)
  end

  # Fields Definition Read
  # GET /admin/api/fields_definitions/{id}.json
  def show
    respond_with(fields_definition)
  end

  # Fields Definition Update
  # PUT /admin/api/fields_definitions/{id}.json
  def update
    fields_definition.update(update_params)
    respond_with(fields_definition)
  end

  # Fields Definition Delete
  # DELETE /admin/api/fields_definitions/{id}.json
  def destroy
    fields_definition.destroy
    respond_with(fields_definition)
  end

  private

  DEFAULT_PARAMS = [:target, :label, :required, :hidden, :read_only, {choices: []}].freeze
  private_constant :DEFAULT_PARAMS

  def fields_definitions
    @fields_definitions ||= current_account.fields_definitions
  end

  def fields_definition
    @fields_definition ||= fields_definitions.find(params[:id])
  end

  def create_params
    params.require(:fields_definition).permit(DEFAULT_PARAMS | %i[name])
  end

  def update_params
    params.require(:fields_definition).permit(DEFAULT_PARAMS | %i[position])
  end

end
