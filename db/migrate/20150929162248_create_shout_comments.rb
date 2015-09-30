class CreateShoutComments < ActiveRecord::Migration
  def change
    create_table :shout_comments do |t|
      t.text :body
      t.references :shout, index: true
      t.references :user, index: true
      t.timestamps
    end
  end
end
