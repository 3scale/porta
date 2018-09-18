module ForumSupport
  module Posts
    def self.included(base)
      base.send :include, ThreeScale::SpamProtection::Integration::Controller

      base.before_action :find_topic
      base.before_action :find_post, :only => [:edit, :update, :destroy]
      base.before_action :authorize_resources

      base.builtin_template_scope = 'forum/posts'
    end

    def index
      # TODO: search
      @posts = parent.posts.paginate(:page => params[:page], :per_page => 20)
    end

    def create
      @post = @topic.posts.build(params[:post])
      @post.user = current_user

      if spam_check_save(@post)
        flash[:notice] = 'Post was successfully created.'
        # TODO: redirect to the last page
        redirect_to forum_topic_url(@topic, :anchor => "new_post")
      else
        render :new
      end
    end

    def edit
    end

    def update
      @post.attributes = params[:post]
      if spam_check_save(@post)
        flash[:notice] = 'Post was successfully updated.'
        redirect_to forum_topic_url(@post.topic)
      else
        render :edit
      end
    end

    def destroy
      @post.destroy

      flash[:notice] = 'Post was successfully deleted.'
      redirect_to forum_topic_url(@post.topic)
    end

    private

    def authorize_resources
      unless @post
        authorize! :reply, @topic
      else
        authorize! params[:action].to_sym, @post
      end
    end

    def find_topic
      @topic = @forum.topics.find_by_permalink!(params[:topic_id]) if params[:topic_id]
    end

    def find_post
      @post = @forum.posts.find(params[:id])
    end

    def parent
      if params[:topic_id]
        @topic
      else
        @forum
      end
    end


    # def show
    #   respond_to do |format|
    #     #FIXME this redirection fails when used on admin, the route is built wrong
    #     format.html { redirect_to forum_topic(@forum, @topic) }
    #     format.xml  do
    #       find_post
    #       render :xml  => @post
    #     end
    #   end
    # end

    # def new
    #   @post = Post.new
    #   @quiz_id = rand(CAPTCHA_QUESTIONS.length) # create the captcha question
    #   respond_to do |format|
    #     format.html
    #     format.xml { render :xml => @post }
    #   end
    # end


    # def human_tested
    #   if @user.anonymous?
    #     verify_recaptcha(:model => @post, :message => "Oh! It's error with reCAPTCHA!")
    #   else
    #     true
    #   end
    # end
  end
end
