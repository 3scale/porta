module ForumSupport::Forums
  def self.included(base)
    base.class_eval do
      include SearchSupport
    end
  end

  def show
    @topic  = @forum.topics.build
    @topics = @forum.topics.smart_search(params[:query], pagination_params)

  end

  private
  def pagination_params
    { page: params[:page] }
  end
end
