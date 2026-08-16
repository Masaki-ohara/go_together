class CreateSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :schedules do |t|
      t.references :group, null: false, foreign_key: true
      t.string :title
      t.date :date

      t.timestamps
    end
  end
end
