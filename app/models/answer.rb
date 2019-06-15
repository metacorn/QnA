class Answer < ApplicationRecord
  belongs_to :question

  validates :body,  presence: true,
                    length: { in: 50..1000 }
end
