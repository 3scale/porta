# frozen_string_literal: true

class Provider::Admin::CMS::BuiltinLegalTermsController < Sites::BaseController
  before_action :activate_menu_for_legal, :find_legal_term

  def new; end

  def edit; end

  def update
    if @page.update(permitted_params.fetch(:cms_template))
      redirect_back_or_to({ action: :edit, id: @page.id }, success: t('.success'))
    else
      render :edit
    end
  end

  def create
    if @page.save
      redirect_to({ action: :edit, id: @page.id }, success: t('.success'))
    else
      render :new
    end
  end

  def activate_menu_for_legal
    system_name = if params[:id].present?
                    templates.find(params[:id])[:system_name]
                  else
                    system_name_param
                  end
    activate_menu :audience, :cms, system_name
  end

  private

  def find_legal_term
    @page = if params[:id].present?
              templates.find(params[:id])
            elsif (system_name = system_name_param)
              templates.find_or_build_by_system_name(system_name, permitted_params[:cms_template])
            else
              raise ActiveRecord::RecordNotFound
            end
  end

  def templates
    current_account.builtin_legal_terms
  end

  def system_name_param
    params[:system_name] || params[:cms_template]&.fetch(:system_name)
  end

  def permitted_params
    params.permit(cms_template: %i[system_name draft])
  end
end
