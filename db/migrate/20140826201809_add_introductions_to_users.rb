class AddIntroductionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :introduction_1, :string, default: ""
    add_column :users, :introduction_2, :string, default: ""
  end
end
