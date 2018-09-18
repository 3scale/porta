class Admin::FieldsDefinitionsController < Sites::BaseController
  respond_to :html
  activate_menu :settings, :fields_definitions

  def index
    @possible_targets = FieldsDefinition.targets

    respond_with(field_definitions)
  end

  def show
    respond_with(field_definition)
  end

  def new
    @fields_definition = field_definitions.build(field_definition_params)

    @optional_fields = @fields_definition.target_class.builtin_fields -
      current_account.fields_definitions.by_target(target).map{ |f|f.name }

    @required_fields = @fields_definition.target_class.required_fields

    @optional_fields.unshift "[new field]"

    respond_with(@fields_definition)
  end

  def edit
    @optional_fields = field_definition.target_class.builtin_fields
    @required_fields = field_definition.target_class.required_fields

    respond_with(field_definition)
  end

  def create
    @fields_definition = field_definitions.build(field_definition_params)

    if @fields_definition.save
      flash[:notice] = 'Field was successfully created.'

    elsif @fields_definition.errors[:target].empty?
      @optional_fields = @fields_definition.target.classify.constantize.builtin_fields -
          current_account.fields_definitions.by_target(@fields_definition.target).map(&:name)
      @required_fields = @fields_definition.target_class.required_fields
      @optional_fields.unshift "[new field]"
    end

    respond_with(@fields_definition, location: admin_fields_definitions_path)
  end

  def update
    @required_fields = []
    if field_definition.update_attributes(field_definition_params)
      @required_fields = field_definition.target_class.required_fields
    end

    respond_with(field_definition, location: admin_fields_definitions_path)
  end

  def destroy
    field_definition.destroy
    respond_with(field_definition, location: admin_fields_definitions_path)
  end

  def sort
    fields = current_account.fields_definitions.find(field_definition_params).index_by(&:id)

    field_definition_params.each_with_index do |field_id, index|
      fields.fetch(field_id.to_i).update_attribute(:pos, index + 1)
    end

    render nothing: true
  end

  private

  def field_definition_params
    params[:fields_definition] || {}
  end

  def target
    field_definition_params[:target]
  end

  def field_definitions
    @fields_definitions ||= current_account.fields_definitions
  end

  def field_definition
    @fields_definition ||= field_definitions.find(params[:id])
  end
end
