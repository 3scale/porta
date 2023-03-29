#frozen_string_literal: true

class Admin::Api::FieldsDefinitionsController < Admin::Api::BaseController

  # we need to include position, because FieldsDefinition is creating it as an alias
  wrap_parameters include: FieldsDefinition.attribute_names + ['position']
  representer FieldsDefinition

  ##~ @parameter_fields_definition_target = {:name => "target", :description => "Target entity of fields definition.", :dataType => "string", :required => true, :paramType => "query", :defaultValue => "account", :allowableValues => {:values => ["Account","User","Cinstance"], :valueType => "LIST"}}

  # swagger
  ##~ sapi = source2swagger.namespace("Account Management API")
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/fields_definitions.json"
  ##~ e.responseClass = "List[fields_definition]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Fields Definitions List"
  ##~ op.description = "Returns the list of all fields definitions."
  ##~ op.group = "fields_definition"
  #
  ##~ op.parameters.add @parameter_access_token
  #
  def index
    respond_with(fields_definitions)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/fields_definitions.json"
  ##~ e.responseClass = "FieldsDefinition"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "Fields Definition Create"
  ##~ op.description = "Creates a new fields definition."
  ##~ op.group = "fields_definition"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_fields_definition_target
  ##~ op.parameters.add :name => "name", :description => "Name of the fields definition to be created.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "label", :description => "The field title your developers will see.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "required", :description => "If 'true' the field will be required for developers.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "hidden", :description => "If 'true' the developers won't be able to see this field.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "read_only", :description => "If 'true' the developers won't be able to change this field.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "choices", :defaultName => "choices[]", :description => "The list of predefined options for this field, URL-encoded array.", :dataType => "custom", :allowMultiple => true, :required => false, :paramType => "query"
  #
  def create
    field_def = fields_definitions.build(create_params)

    field_def.save

    respond_with(field_def)
  end

  # swagger
  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/fields_definitions/{id}.json"
  ##~ e.responseClass = "service"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "Fields Definition Read"
  ##~ op.description = "Returns the fields definition by id."
  ##~ op.group = "fields_definition"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "id", :description => "ID of the fields definition.", :dataType => "int", :required => true, :paramType => "path"
  #
  def show
    respond_with(fields_definition)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Fields Definition Update"
  ##~ op.description = "Updates the fields definition."
  ##~ op.group = "fields_definition"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "id", :description => "ID of the fields definition.", :dataType => "int", :required => true, :paramType => "path"
  ##~ op.parameters.add @parameter_fields_definition_target
  ##~ op.parameters.add :name => "label", :description => "The field title your developers will see.", :dataType => "string", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "required", :description => "If 'true' the field will be required for developers.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "hidden", :description => "If 'true' the developers won't be able to see this field.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "read_only", :description => "If 'true' the developers won't be able to change this field.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "position", :description => "Position of the fields definition.", :dataType => "integer", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "choices", :defaultName => "choices[]", :description => "The list of predefined options for this field, URL-encoded array.", :dataType => "custom", :allowMultiple => true, :required => false, :paramType => "query"
  #
  def update
    fields_definition.update(update_params)
    respond_with(fields_definition)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "DELETE"
  ##~ op.summary    = "Fields Definition Delete"
  ##~ op.description = "Deletes the fields definition."
  ##~ op.group = "fields_definition"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "id", :description => "ID of the fields definition.", :dataType => "int", :required => true, :paramType => "path"
  #
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
