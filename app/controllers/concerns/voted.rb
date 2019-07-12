module Voted
  extend ActiveSupport::Concern

  def vote_up
    vote!(:positive)
  end

  def vote_down
    vote!(:negative)
  end

  private

  def vote!(kind)
    model_klass = controller_name.classify.constantize
    votable = model_klass.find(params[:id])
    return head :forbidden if current_user.owner?(votable)
    vote = votable.votes.new(user: current_user, votable: votable, kind: kind)

    respond_to do |format|
      if vote.save
        format.json { render json: {
          rating: votable.rating,
          kind: kind
        } }
      else
        format.json { render json: vote.errors }
      end
    end
  end
end
