# TODO: the section juggling in create/update should eventually go to model.
# The idea is that by default the section should be root section but this leaves
# a bunch of untested branches out of the scope of this PR (e.g. does the account has a root section...)
class Admin::Api::CMS::FilesController < Admin::Api::CMS::BaseController
  ##~ sapi = source2swagger.namespace("CMS API")
  ##~ sapi.resourcePath = "/admin/api/cms/templates"
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  #
  ##~ @parameter_file_id = { :name => "id", :description => "ID of the file", :dataType => "int", :required => true, :paramType => "path" }

  MAX_PER_PAGE = 100
  DEFAULT_PER_PAGE = 20

  before_action :find_file, only: [:show, :edit, :update, :destroy]

  representer :entity => ::CMS::FileRepresenter, :collection => ::CMS::FilesRepresenter

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/cms/files.xml"
  ##~ e.responseClass = "List[short-file]"
  #
  ##~ op            = e.operations.add
  ##~ op.httpMethod = "GET"
  ##~ op.summary    = "File List"
  ##~ op.description = "List all files"
  ##~ op.group = "cms_files"
  #
  ##~ op.parameters.add @parameter_page
  ##~ op.parameters.add @parameter_per_page
  ##~ op.parameters.add @parameter_access_token
  def index
    files = (if params[:section_id]
      current_account.sections.find_by_id_or_system_name!(params[:section_id]).files
             else
      current_account.files
    end).paginate(page: params[:page] || 1, per_page: per_page)

    respond_with files
  end

  ##~ op            = e.operations.add
  ##~ op.httpMethod = "POST"
  ##~ op.summary    = "File Create"
  ##~ op.description = "Create file"
  ##~ op.group = "cms_files"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add :name => "path", :description => "URI of the file", :paramType => "query", :required => true
  ##~ op.parameters.add :name => "section_id", :description => "ID of a section (valid only for pages)", :type => "int", :default => "root section id", :paramType => "query"
  ##~ op.parameters.add :name => "tag_list", :description => "List of the tags", :paramType => "query"
  ##~ op.parameters.add :name => "attachment", :paramType => "query", :required => true
  ##~ op.parameters.add :name => "downloadable", :description => "Checked sets the content-disposition to attachment", :type => "boolean", :paramType => "query", :default => "false"
  def create
    @file = current_account.files.build(file_params)
    @file.section = current_account.sections.find_by_id(params[:section_id]) || current_account.sections.root
    @file.save

    respond_with @file
  end

  ##~ e = sapi.apis.add
  ##~ e.path = "/admin/api/cms/files/{id}.xml"
  ##~ e.responseClass = "file"
  #
  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "GET"
  ##~ op.summary     = "File Read"
  ##~ op.description = "View file"
  ##~ op.group       = "cms_files"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_file_id
  def show
    respond_with @file
  end

  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "PUT"
  ##~ op.summary     = "File Update"
  ##~ op.description = "Update file"
  ##~ op.group       = "cms_files"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_file_id
  ##~ op.parameters.add :name => "path", :description => "URI of the file", :paramType => "query"
  ##~ op.parameters.add :name => "section_id", :description => "ID of a section (valid only for pages)", :type => "int", :default => "root section id", :paramType => "query"
  ##~ op.parameters.add :name => "tag_list", :description => "List of the tags", :paramType => "query"
  ##~ op.parameters.add :name => "attachment", :paramType => "query"
  ##~ op.parameters.add :name => "downloadable", :description => "Checked sets the content-disposition to attachment", :type => "boolean", :paramType => "query", :default => "false"
  def update
    @file.section = current_account.sections.find_by_id(params[:section_id]) if params[:section_id]
    @file.update_attributes(file_params)
    respond_with @file
  end

  ##~ op             = e.operations.add
  ##~ op.httpMethod  = "DELETE"
  ##~ op.summary     = "File Delete"
  ##~ op.description = "Delete file"
  ##~ op.group       = "cms_files"
  #
  ##~ op.parameters.add @parameter_access_token
  ##~ op.parameters.add @parameter_file_id
  def destroy
    @file.destroy
    respond_with @file, location: admin_api_cms_files_path(@file)
  end

  private

  def find_file
    @file = current_account.files.find(params[:id])
  end

  # wrap_parameters don't work with the attachment
  def file_params
    [:path, :tag_list, :attachment, :downloadable].inject({}) do |hash, key|
      hash[key] = params[key] unless params[key].nil?
      hash
    end
  end

end
