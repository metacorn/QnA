class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question

  default_scope { order(best: :desc, created_at: :asc) }
  scope :best, -> { where(best: true) }

  validates :body,  presence: true,
                    length: { minimum: 50 }
  validate :only_one_best_per_question

  def mark_as_best
    transaction do
      question.answers.best.update_all(best: false)
      self.update!(best: true)
    end
  end

  private

  def only_one_best_per_question
    return unless best?
    return unless question&.answers.best.any?

    if persisted?
      # update
      errors.add(:best, :there_is_the_best_answer_in_question_already) if changes['best'] == [false, true]
    else
      # create
      errors.add(:best, :there_is_the_best_answer_in_question_already)
    end
  end
end
