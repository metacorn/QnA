class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question

  default_scope { order :created_at }

  validates :body,  presence: true,
                    length: { minimum: 50 }

  def mark_as_best
    transaction do
      question.answers.update_all(best: false)
      self.update!(best: true)
    end
  end
end
