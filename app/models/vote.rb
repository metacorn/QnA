class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true
  belongs_to :user

  scope :by_user, -> (user) { where('user_id = ?', user&.id) }

  validates :value, presence: true, inclusion: { in: [-1, 1] }
  validates :user, uniqueness: { scope: [:votable_type, :votable_id], message: 'user has already voted for/against this resource' }

  class << self
    def like(params = {})
      new(params.merge(value: 1))
    end

    def dislike(params = {})
      new(params.merge(value: -1))
    end
  end
end
