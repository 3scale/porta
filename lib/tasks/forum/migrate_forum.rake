namespace :forum do

  desc 'Migrate all content from one forum to another'
  task migrate_forum: :environment do

    current_forum_id = ENV['CURRENT_FORUM_ID']
    new_forum_id     = ENV['NEW_FORUM_ID']

    if current_forum_id.blank? || new_forum_id.blank?
      raise "CURRENT_FORUM_ID & NEW_FORUM_ID variables are required"
    end

    current_forum = Forum.find(current_forum_id)
    new_forum     = Forum.find(new_forum_id)

    current_author_id = current_forum.topics.pluck(:user_id).uniq.compact.first
    p "author of the current forum content: #{current_author_id}"

    new_author_id = new_forum.account.users.last.id
    p "author of the new forum content: #{new_author_id}"

    ActiveRecord::Base.transaction do
      p 'migrate topics'
      current_forum.topics.update_all forum_id: new_forum.id, tenant_id: new_forum.tenant_id

      p 'migrate posts'
      current_forum.posts.update_all forum_id: new_forum.id, tenant_id: new_forum.tenant_id

      p 'migrate topic\'s author'
      new_forum.topics.where(user_id: current_author_id).update_all user_id: new_author_id

      p 'migrate post\'s author'
      new_forum.posts.where(user_id: current_author_id).update_all user_id: new_author_id

      p 'migrate topic categories'
      current_forum.categories.update_all forum_id: new_forum.id, tenant_id: new_forum.tenant_id
    end
  end
end
