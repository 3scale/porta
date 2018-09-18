# here we define abilities for all users without caring about his role
Ability.define do |user|
  if user
    # Anyone can read their own account.
    can(:read, Account) { |account| user.account == account }

    # redundant with one above?
    can :read, Account, :account => {:id => user.account.id}

    # anyone can destroy own topics in one day from creation
    can [:edit, :update, :destroy], Topic do |topic|
      # there seem to be topics with created_at nil
      topic.user == user && topic.created_at && topic.created_at >= 1.day.ago
    end

    # anyone can destroy own posts in one day from creation
    can [:edit, :update, :destroy], Post do |post|
      # there seem to be posts with created_at nil
      post.user == user && post.created_at && post.created_at >= 1.day.ago
    end

  else # non logged users
    can :read, Topic do |topic|
      topic.forum.public?
    end

    can :read, TopicCategory do |category|
      category.forum.public?
    end

    can :reply, Topic do |topic|
      # TODO: maybe also check for can?(:read, topic)
      forum = topic.forum || topic.category.try!(:forum)
      forum.anonymous_posts_enabled?
    end
  end

  can :reply, Post do |post|
    can? :reply, post.topic
  end

  cannot :destroy, Post do |post|
    post.topic.posts.count <= 1
  end

end
