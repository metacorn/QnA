class AddVotableToAnswers < ActiveRecord::Migration[5.2]
  def change
    add_reference :answers, :votable, polymorphic: true
  end
end
