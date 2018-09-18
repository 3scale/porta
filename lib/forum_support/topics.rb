module ForumSupport::Topics
  def self.included(base)
    base.send :include, ThreeScale::SpamProtection::Integration::Controller

    base.before_action :find_topic, :only => [:show, :edit, :update, :destroy]
    base.before_action :authorize_topic

    base.builtin_template_scope = 'forum/topics'

    base.respond_to :html
  end

  def my
    @topics = @forum.topics.with_post_by(current_user).paginate(:page => params[:page])
    @my = true

    respond_with @topics
  end

  def show
    @topic.hit!
    @posts = @topic.posts.includes(:topic, :user).paginate(:page => params[:page], :per_page => 20)
    @post  = @topic.posts.build

    respond_with @topic
  end

  def new
    @topic = @forum.topics.build
    @topic.category = category(params[:category])

    respond_with @topic
  end

  def create
    @topic = @forum.topics.build(topic_params)
    set_protected_attributes

    if spam_check_save(@topic)
      flash[:notice] = "Thread was successfully created."
      redirect_to forum_topic_url(@topic)
    else
      render :new
    end
  end

  def edit
    respond_with @topic
  end

  def update
    @topic.attributes = topic_params
    set_protected_attributes

    if spam_check_save(@topic)
      flash[:notice] = "Thread was successfully updated."
      redirect_to forum_topic_url(@topic)
    else
      render :edit
    end
  end

  def destroy
    @topic.destroy

    flash[:notice] = "Thread was successfully deleted."
    redirect_to forum_url
  end

  private

  def authorize_topic
    if @topic
      # there is no :show permission, but :read
      if params[:action].to_sym == :show
        authorize! :read, @topic
      else # other permissions should be ok
        authorize! params[:action].to_sym, @topic
      end
    else
      # creating new forum
      authorize! :reply, @forum.topics.build
    end
  end

  def find_topic
     @topic = @forum.topics.find_by_permalink!(params[:id])
  end

  def set_protected_attributes
    @topic.user   = current_user
    @topic.category = category

    @topic.sticky = topic_params.fetch(:sticky, @topic.sticky) if can?(:stick, @topic)
    @topic.locked = topic_params.fetch(:locked, @topic.locked) if can?(:lock, @topic)
  end

  def topic_params
    params.require(:topic)
  end

  def category(category_id = topic_params[:category_id])
    if category_id
      @forum.categories.find(category_id)
    end
  end

  # def human_tested
  #   if @user.anonymous?
  #     verify_recaptcha(:model => @post, :message => "Oh! It's error with reCAPTCHA!")
  #   else
  #     true
  #   end
  # end
end
