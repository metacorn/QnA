class AddVotableToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_reference :questions, :votable, polymorphic: true
  end
end
