class AddGroupToPlans < ActiveRecord::Migration[7.2]
  def change
    add_reference :plans, :group, foreign_key: true
  end
end
