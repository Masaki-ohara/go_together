class AddStartAndEndTimeToPlanItems < ActiveRecord::Migration[7.2]
  def change
    add_column :plan_items, :start_time, :string
    add_column :plan_items, :end_time, :string
  end
end
