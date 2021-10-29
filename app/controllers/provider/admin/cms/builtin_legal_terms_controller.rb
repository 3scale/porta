class Provider::Admin::CMS::BuiltinLegalTermsController < Sites::BaseController

  sublayout 'sites/legal_terms'

  before_action :activate_menu_for_legal, :find_legal_term

  def new
  end

  def edit
  end

  def update
    if @page.update_attributes(params[:cms_template])
      flash[:info] = 'Legal terms saved.'
      redirect_back(fallback_location: { action: "edit", id: @page.id})
    else
      render :edit
    end
  end

  def create
    if @page.save
      flash[:info] = 'Legal terms saved.'
      redirect_to action: :edit, id: @page.id
    else
      render :new
    end
  end

  def activate_menu_for_legal
    system_name = if params[:id].present?
                    templates.find(params[:id])[:system_name]
                  else 
                    params[:system_name] || params[:cms_template].try!(:fetch,:system_name)
                  end
    self.activate_menu :audience, :cms, system_name
  end

  private

  def find_legal_term
    @page = if params[:id].present?
              templates.find(params[:id])
            elsif system_name = params[:system_name] || params[:cms_template].try!(:fetch,:system_name)
              templates.find_or_build_by_system_name(system_name, params[:cms_template])
            else
              raise ActiveRecord::RecordNotFound
            end
  end

  def templates
    current_account.builtin_legal_terms
  end

end
