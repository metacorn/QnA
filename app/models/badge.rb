class Badge < ApplicationRecord
  belongs_to :question
  belongs_to :answer, optional: true
  belongs_to :user, optional: true

  has_one_attached :image

  validates :name, :image, presence: true
  validate :validate_answer_corectness
  validate :validate_user_corectness

  private

  def validate_answer_corectness
    if answer
      unless answer.question == question
        errors.add(:answer, "answer is for another question")
      end
    end
  end

  def validate_user_corectness
    if user && answer
      unless answer.user == user
        errors.add(:user, "is not an author of an answer")
      end
    end
  end
end
