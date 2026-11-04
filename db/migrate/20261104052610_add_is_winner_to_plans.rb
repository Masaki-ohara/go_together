class AddIsWinnerToPlans < ActiveRecord::Migration[7.2]
  def change
    add_column :plans, :is_winner, :boolean
  end
end
