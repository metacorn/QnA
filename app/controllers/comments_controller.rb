class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable, only: %i[create]
  after_action :publish_comments, only: %i[create]

  authorize_resource

  def create
    @comment = @commentable.comments.new(commentable_params)
    @comment.update(user: current_user)
    @comment.save
  end

  private

  def set_commentable
    commentable_key = params.keys.select { |key| key.to_s.match(/.+_id\z/) }.first
    commentable_id = params[commentable_key]
    commentable_klass = commentable_key.chomp('_id').pluralize.classify.constantize
    @commentable = commentable_klass.find(commentable_id)
  end

  def commentable_params
    params.require(:comment).permit(:body)
  end

  def publish_comments
    return if @comment.errors.any?

    if @commentable.is_a?(Question)
      @question = @commentable
    elsif @commentable.is_a?(Answer)
      @question = @commentable.question
    end

    CommentsChannel.broadcast_to(@question,
                                comment: @comment)
  end
end
