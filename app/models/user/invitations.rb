module User::Invitations
  extend ActiveSupport::Concern

  included do
    after_commit :accept_invitation, :on => :create

    attr_accessor :invitation
    attr_accessible :invitation

    # TODO: refactor to make this work removing above attribute.
    # has_one :invitation

    before_destroy  :destroy_invitation
  end

  def accept_invitation
    invitation && invitation.accept!
  end

  def destroy_invitation
    if account # some tests fail because of account being nil
      invit = account.invitations.find_by_email(email) || account.invitations.find_by_user_id(id) # || eventually invitation
      # halt the destruction if the destruction of invitation failed
      throw :abort if invit && invit.destroy == false
    end
  end
end
