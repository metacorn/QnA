module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def cancel_vote_of(user)
    vote = votes.by_user(user)
    (vote.any?) ? vote.destroy_all : false
  end

  def rating
    votes.sum(:value)
  end

  def liked?(user)
    votes.by_user(user).first&.value == 1
  end

  def disliked?(user)
    votes.by_user(user).first&.value == -1
  end
end
