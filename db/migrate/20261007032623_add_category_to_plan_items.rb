class AddCategoryToPlanItems < ActiveRecord::Migration[7.2]
  def change
    add_column :plan_items, :category, :string
  end
end
