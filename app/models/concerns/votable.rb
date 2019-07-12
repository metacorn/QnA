module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy

    validate :validate_rating_is_integer
  end

  def rating
    votes.positive.count - votes.negative.count
  end

  private

  def validate_rating_is_integer
    errors.add(:rating, "is not integer") unless rating.instance_of?(Integer)
  end
end
