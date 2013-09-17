class Messages::TopicsController < ApplicationController
  respond_to :html

  def index
    respond_with @topics = current_user.topics
  end

  def show
    respond_with @topic = Messages::Topic.find(params[:id])
  end

  def new
    @topic = Messages::Topic.new
    respond_with @topic
  end

  def create
    @topic = Messages::Topic.new(topic_params)
    @topic.creator = current_user
    respond_with @topic
  end

  private

  def topic_params
    params[:messages_topic].permit(:circle_id, :circle_type, :include_professor, :subject)
  end
end
