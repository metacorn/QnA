module Voted
  extend ActiveSupport::Concern

  included do
    before_action :set_votable, only: %i[vote_up vote_down cancel_vote]
  end

  def vote_up
    vote!(1)
  end

  def vote_down
    vote!(-1)
  end

  def cancel_vote
    return head :forbidden if current_user.owner?(@votable)
    vote = @votable.votes.by_user(current_user).first

    respond_to do |format|
      if vote&.destroy
        format.json { render json: {
          down_vote_state: 'active',
          rating: @votable.rating,
          up_vote_state: 'active',
          cancel_vote_state: 'inactive',
          votable_controller: controller_name,
          votable_id: @votable.id
        } }
      else
        format.json { render json: "resource has no this user's votes" }
      end
    end
  end

  private

  def set_votable
    model_klass = controller_name.classify.constantize
    @votable = model_klass.find(params[:id])
  end

  def vote!(value)
    return head :forbidden if current_user.owner?(@votable)
    vote = @votable.votes.new(user: current_user, votable: @votable, value: value)

    respond_to do |format|
      if vote.save
        down_vote_state = (value == 1 ? 'inactive' : 'highlighted')
        up_vote_state = (value == -1 ? 'inactive' : 'highlighted')

        format.json { render json: {
          down_vote_state: down_vote_state,
          rating: @votable.rating,
          up_vote_state: up_vote_state,
          cancel_vote_state: 'active',
          votable_controller: controller_name,
          votable_id: @votable.id
        } }
      else
        format.json { render json: vote.errors }
      end
    end
  end
end
