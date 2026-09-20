class AddPlanToSchedules < ActiveRecord::Migration[7.2]
  def change
    add_reference :schedules, :plan, foreign_key: true
  end
end
