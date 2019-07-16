class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.integer :value
      t.references :votable, polymorphic: true
      t.references :user, foreign_key: true
    end
  end
end
