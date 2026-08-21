module User::Invitations
  extend ActiveSupport::Concern

  included do
    after_commit :accept_invitation, :on => :create

    has_one :invitation, dependent: nil

    before_destroy :destroy_invitation
  end

  def accept_invitation
    invitation && invitation.accept!
  end

  def destroy_invitation
    if account # some tests fail because of account being nil
      invitations = account.invitations
      invit = invitations.find_by(email: email) || invitations.find_by(user_id: id)
      # halt the destruction if the destruction of invitation failed
      throw :abort if invit && invit.destroy == false
    end
  end
end
