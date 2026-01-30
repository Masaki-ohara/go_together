class AddTitleToPlans < ActiveRecord::Migration[7.2]
  def change
    add_column :plans, :title, :string
  end
end
