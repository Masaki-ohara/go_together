class CreateScheduleItems < ActiveRecord::Migration[7.2]
  def change
    create_table :schedule_items do |t|
      t.references :schedule, null: false, foreign_key: true
      t.string :start_time
      t.string :content

      t.timestamps
    end
  end
end
