class AddTimestampsToBlockUser < ActiveRecord::Migration
    def change
        change_table(:block_users) { |t| t.timestamps }
    end
end