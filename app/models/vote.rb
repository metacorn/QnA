class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true
  belongs_to :user

  enum kind: [ :positive, :negative ]

  scope :positive, -> { where(kind: 'positive') }
  scope :negative, -> { where(kind: 'negative') }
  scope :by_user, -> (user) { where('user_id = ?', user.id) }

  validate :validate_only_one_users_vote

  private

  def validate_only_one_users_vote
    if votable
      last_users_vote = votable.votes.by_user(user).last
      return unless last_users_vote

      if last_users_vote.kind == "positive"
        errors.add(:user, "has voted for this #{votable.class.to_s.underscore} already")
      elsif last_users_vote.kind == "negative"
        errors.add(:user, "has voted against this #{votable.class.to_s.underscore} already")
      end
    end
  end
end
