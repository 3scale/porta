#frozen_string_literal: true

class Admin::Api::FieldsDefinitionsController < Admin::Api::BaseController
  # token scope?

  wrap_parameters FieldsDefinition
  representer FieldsDefinition

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
    respond_with(field_definitions)
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
  ##~ op.parameters.add :name => "target", :description => "Target entity of fields definition.", :dataType => "string", :required => true, :paramType => "query", :defaultValue => "account", :allowableValues => {:values => ["user", "cinstance"], :valueType => "LIST"}}
  ##~ op.parameters.add :name => "name", :description => "Name of the fields definition to be created.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "label", :description => "The field title your developers will see.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "required", :description => "Makes the field required for developers.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "hidden", :description => "Developers won't be able to see this field.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "read_only", :description => "Developers won't be able to change this field.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "choices", :defaultName => "choices[]", :description => "Predefined options for this field. URL-encoded array containing one or more options. For example [\"one\", \"two\"].", :dataType => "custom", :allowMultiple => true, :required => false, :paramType => "query"
  #
  def create
    field_def = field_definitions.build(create_params)

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
    respond_with(field_definition)
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "PUT"
  ##~ op.summary    = "Fields Definition Update"
  ##~ op.description = "Updates the fields definition."
  ##~ op.group = "fields_definition"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "id", :description => "ID of the fields definition.", :dataType => "int", :required => true, :paramType => "path"
  ##~ op.parameters.add :name => "target", :description => "Target entity of fields definition.", :dataType => "string", :required => true, :paramType => "query", :defaultValue => "account", :allowableValues => {:values => ["user", "cinstance"], :valueType => "LIST"}}
  ##~ op.parameters.add :name => "name", :description => "Name of the fields definition to be created.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "label", :description => "The field title your developers will see.", :dataType => "string", :required => true, :paramType => "query"
  ##~ op.parameters.add :name => "required", :description => "Makes the field required for developers.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "hidden", :description => "Developers won't be able to see this field.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "read_only", :description => "Developers won't be able to change this field.", :dataType => "boolean", :required => false, :paramType => "query"
  ##~ op.parameters.add :name => "choices", :defaultName => "choices[]", :description => "Predefined options for this field. URL-encoded array containing one or more options. For example [\"one\", \"two\"].", :dataType => "custom", :allowMultiple => true, :required => false, :paramType => "query"
  #
  def update
    field_definition.update_attributes(update_params)
    respond_with(field_definition)
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
    field_definition.destroy
    respond_with(field_definition)
  end

  private

  DEFAULT_PARAMS = %i[target label name choices required hidden read_only].freeze

  def field_definitions
    @fields_definitions ||= current_account.fields_definitions
  end

  def field_definition
    @fields_definition ||= field_definitions.find(params[:id])
  end

  def create_params
    params.require(:field_definition).permit(DEFAULT_PARAMS)
  end

  def update_params
    params.require(:field_definition).permit(DEFAULT_PARAMS)
  end

end

