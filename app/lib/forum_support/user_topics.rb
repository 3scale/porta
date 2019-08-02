module ForumSupport
  module UserTopics
    def self.included(base)
      base.class_eval do
        before_action :login_required
      end

      base.builtin_template_scope = 'forum/user_topics'
    end

    def index
      @user_topics = current_user.user_topics.paginate(:page => params[:page])

      respond_to do |format|
        format.html
        format.xml  { render :xml => @user_topics }
      end
    end

    def create
      @user_topic = UserTopic.new :user => current_user

      # ensuring the topic belongs to the site_account forum
      @user_topic.topic = @forum.topics.find_by_id(params[:user_topic][:topic_id])

      respond_to do |format|
        if @user_topic.save
           flash[:notice] = 'You have successfully subscribed to the thread.'
        end
        format.html { redirect_to :back }
      end
    end

    # beware that what's passed as params[:id] is the topic id
    def destroy
      topic = Topic.find params[:id]
      user_topic = current_user.user_topics.find_by_topic_id!(topic.id)
      user_topic.destroy

      respond_to do |format|
        flash[:notice] = 'You have successfully unsubscribed from the thread.'
        format.html { redirect_to :back }
      end
    end
  end
end
