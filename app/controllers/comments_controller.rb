class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable

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
end
