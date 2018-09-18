# TODO: It's not clear why is this a separate module. Consider merging it with AuthenticatedSystem
module AccessControl
  def self.included(base)
    base.rescue_from CanCan::AccessDenied do |e|
      access_denied(e)
    end
  end

  private

  def unauthenticated
    respond_to do |format|
      format.html { request_login }

      # XXX: Not sure why this is sometimes not caught by the html branch.
      format.url_encoded_form { request_login }

      format.any { handle_access_denied(CanCan::AccessDenied.new) }
    end
  end

  def access_denied(e)
    if logged_in?
      handle_access_denied(e)
    else
      request_login
    end
  end

end
