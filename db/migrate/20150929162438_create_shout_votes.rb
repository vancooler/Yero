class CreateShoutVotes < ActiveRecord::Migration
  def change
    create_table :shout_votes do |t|
      t.references :shout, index: true
      t.references :user
      t.timestamps
    end
  end
end
