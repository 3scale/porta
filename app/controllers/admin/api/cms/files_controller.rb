##= $:.unshift(File.expand_path(File.dirname(__FILE__)))
##= require 'app/lib/three_scale/api/sour'
##=
##= namespace 'CMS API'
##= resourcePath '/admin/api/cms/files'
##= swaggerVersion "1.1"
##= apiVersion "1.0"
##=
##= module Threescale::Api::Sour::Operation
##=    def file_model_params
##=      param 'path', 'URI of the file'
##=      param 'section_id', 'ID of a section (valid only for pages)', default: 'root section id', type: 'int'
##=      param 'tag_list', 'List of tags'
##=      param 'attachment'
##=      param 'downloadable', 'Checked sets the content-disposition to attachment', default: 'false', type: 'boolean'
##=    end
##=  end
##=
##=
##= Sour::Operation.mixin(Threescale::Api::Sour::Operation)
##=
##=

# TODO: the section juggling in create/update should eventually go to model.
# The idea is that by default the section should be root section but this leaves
# a bunch of untested branches out of the scope of this PR (e.g. does the account has a root section...)
class Admin::Api::CMS::FilesController < Admin::Api::CMS::BaseController

  MAX_PER_PAGE = 100
  DEFAULT_PER_PAGE = 20

  before_action :find_file, only: [:show, :edit, :update, :destroy]

  representer :entity => ::CMS::FileRepresenter, :collection => ::CMS::FilesRepresenter

  ##=  api("/admin/api/cms/files.xml", 'List[short-file]') {
  ##=    GET('List all files') {
  ##=      paginated
  ##=      requires_access_token
  ##=    }
  def index
    files = (if params[:section_id]
      current_account.sections.find_by_id_or_system_name!(params[:section_id]).files
             else
      current_account.files
    end).paginate(page: params[:page] || 1, per_page: per_page)

    respond_with files
  end

  ##=    POST('Create file') {
  ##=      requires_access_token
  ##=      file_model_params
  ##=    }
  ##=  }
  ##=
  def create
    @file = current_account.files.build(file_params)
    @file.section = current_account.sections.find_by_id(params[:section_id]) || current_account.sections.root
    @file.save

    respond_with @file
  end

  ##=   api("/admin/api/cms/files/{id}.xml", 'file') {
  ##=     GET('View file') {
  ##=       requires_access_token
  ##=       id 'ID of the file'
  ##=     }
  ##=
  def show
    respond_with @file
  end

  ##=     PUT('Update file') {
  ##=       requires_access_token
  ##=       id 'ID of the file'
  ##=       file_model_params
  ##=     }
  def update
    @file.section = current_account.sections.find_by_id(params[:section_id]) if params[:section_id]
    @file.update_attributes(file_params)
    respond_with @file
  end

  ##=       DELETE('Delete file'){
  ##=         requires_access_token
  ##=         id 'ID of the file'
  ##=         file_model_params
  ##=       }
  ##=   }
  ##=
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
