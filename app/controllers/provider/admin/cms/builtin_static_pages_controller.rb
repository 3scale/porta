class Provider::Admin::CMS::BuiltinStaticPagesController < Provider::Admin::CMS::BuiltinPagesController

  private

  def templates
    # Return 404 when trying to edit all existing forum templates. TODO: Remove forums THREESCALE-6714
    current_account.builtin_static_pages
                   .where('system_name NOT LIKE "%forum%"')
  end

 end
