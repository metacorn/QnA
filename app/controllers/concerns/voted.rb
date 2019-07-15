module Voted
  extend ActiveSupport::Concern

  included do
    before_action :set_votable, only: %i[vote_up vote_down cancel_vote]
    before_action :check_votable_owner, only: %i[vote_up vote_down cancel_vote]
  end

  def vote_up
    vote = Vote.like(user: current_user, votable: @votable)
    respond_to do |format|
      if vote.save
        format.json { render json: {
          down_vote_state: 'inactive',
          rating: @votable.rating,
          up_vote_state: 'highlighted',
          cancel_vote_state: 'active',
          votable_controller: controller_name,
          votable_id: @votable.id
        } }
      else
        format.json { render json: vote.errors }
      end
    end
  end

  def vote_down
    vote = Vote.dislike(user: current_user, votable: @votable)
    respond_to do |format|
      if vote.save
        format.json { render json: {
          down_vote_state: 'highlighted',
          rating: @votable.rating,
          up_vote_state: 'inactive',
          cancel_vote_state: 'active',
          votable_controller: controller_name,
          votable_id: @votable.id
        } }
      else
        format.json { render json: vote.errors }
      end
    end
  end

  def cancel_vote
    respond_to do |format|
      if @votable.cancel_vote_of(current_user)
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

  def check_votable_owner
    return head :forbidden if current_user&.owner?(@votable)
  end
end
