class AddTimeToPlanItems < ActiveRecord::Migration[7.2]
  def change
    add_column :plan_items, :time, :string
  end
end
