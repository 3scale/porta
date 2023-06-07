# TODO: the section juggling in create/update should eventually go to model.
# The idea is that by default the section should be root section but this leaves
# a bunch of untested branches out of the scope of this PR (e.g. does the account has a root section...)
class Admin::Api::CMS::FilesController < Admin::Api::CMS::BaseController

  MAX_PER_PAGE = 100
  DEFAULT_PER_PAGE = 20
  ALLOWED_PARAMS = %i[section_id path attachment downloadable].freeze

  before_action :find_file, only: [:show, :edit, :update, :destroy]

  wrap_parameters :file, include: ALLOWED_PARAMS

  representer :entity => ::CMS::FileRepresenter, :collection => ::CMS::FilesRepresenter

  # File List
  # GET /admin/api/cms/files.json
  def index
    files = current_account.files.scope_search(search).paginate(pagination_params)

    respond_with files
  end

  # File Create
  # POST /admin/api/cms/files.json
  def create
    @file = current_account.files.build(file_params)
    @file.section = current_account.sections.find_by(id: params[:section_id]) || current_account.sections.root
    @file.save

    respond_with @file
  end

  # File Read
  # GET admin/api/cms/files/{id}.json
  def show
    respond_with @file
  end

  # File Update
  # PUT admin/api/cms/files/{id}.json
  def update
    @file.update(file_params)
    respond_with @file
  end

  # File Delete
  # DELETE admin/api/cms/files/{id}.json
  def destroy
    @file.destroy
    respond_with @file, location: admin_api_cms_files_path(@file)
  end

  private

  def find_file
    @file = current_account.files.find(params[:id])
  end

  def file_params
    params.require(:file).permit(ALLOWED_PARAMS)
  end

end
