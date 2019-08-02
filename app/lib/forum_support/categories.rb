module ForumSupport
  module Categories
    def self.included(base)
      base.before_action :find_category, :only => [:show, :edit, :update, :destroy]
      base.authorize_resource :class => TopicCategory, :instance_name => :category

      base.builtin_template_scope = 'forum/categories'
    end

    def index
      @categories = @forum.categories :include => :topics
    end

    def show
      @topics = @category.topics.paginate(:page => params[:page])
      @topic  = @category.topics.build
    end

    def new
      @category = @forum.categories.build
    end

    def create
      @category = @forum.categories.build(params[:topic_category])

      if @category.save
        flash[:notice] = "Category was successfully created."
        redirect_to forum_categories_url
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @category.update_attributes(params[:topic_category])
        flash[:notice] = "Category was successfully updated."
        redirect_to forum_categories_url
      else
        render :edit
      end
    end

    def destroy
      @category.destroy

      flash[:notice] = "Category was successfully deleted."
      redirect_to forum_categories_url
    end

    private

    def find_category
      @category = @forum.categories.find(params[:id])
    end
  end
end
