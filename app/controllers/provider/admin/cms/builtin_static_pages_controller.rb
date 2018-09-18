class Provider::Admin::CMS::BuiltinStaticPagesController < Provider::Admin::CMS::BuiltinPagesController

  private

  def templates
    current_account.builtin_static_pages
  end

 end
