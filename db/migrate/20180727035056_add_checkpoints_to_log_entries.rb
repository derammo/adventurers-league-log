class AddCheckpointsToLogEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :log_entries, :advancement_checkpoints, :integer
    add_column :log_entries, :treasure_checkpoints, :integer
    add_column :log_entries, :treasure_tier, :integer

    add_column :log_entries, :old_format, :boolean, default: false, null: false
    LogEntry.update_all(old_format: true)
  end
end
