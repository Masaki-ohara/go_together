class AddEndTimeToScheduleItems < ActiveRecord::Migration[7.2]
  def change
    add_column :schedule_items, :end_time, :string
  end
end
