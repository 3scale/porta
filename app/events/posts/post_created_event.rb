class Posts::PostCreatedEvent < AccountRelatedEvent
  class << self
    def create(post)
      # user could be anonymous
      attributes = if post.user.blank?
                     main_attributes(post)
                   else
                     main_attributes(post).merge(user_attributes(post.user))
                   end

      # blank attributes cannot be stored
      # otherwise notification would be considered as invalid
      new(attributes)
    end

    private

    def main_attributes(post)
      {
        post:     post,
        forum:    post.forum,
        provider: provider = post.forum.account,
        metadata: {
          provider_id: provider.id
        }
      }
    end

    def user_attributes(user)
      {
        user:    user,
        account: user.account
      }
    end
  end
end
