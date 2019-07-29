class CreateAuthorizations < ActiveRecord::Migration[5.2]
  def change
    create_table :authorizations do |t|
      t.references :user, foreign_key: true
      t.string :provider
      t.string :uid
      t.string :oauth_email
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      t.timestamps
    end

    add_index :authorizations, [:provider, :uid], unique: true
    add_index :authorizations, [:provider, :oauth_email], unique: true
    add_index :authorizations, :confirmation_token, unique: true
  end
end
