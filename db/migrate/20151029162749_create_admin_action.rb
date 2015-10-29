class CreateAdminAction < ActiveRecord::Migration
  def change
    create_table :admin_actions do |t|
        t.integer  :admin_user_id,       null: false
        t.string   :action_type,         default: ""
        t.text     :details,             default: ""
        t.text     :reason,              default: ""

        t.timestamps
    end

    add_index :admin_actions, ["admin_user_id"],     :name => "index_admin_actions_on_admin_user_id"
  end
end