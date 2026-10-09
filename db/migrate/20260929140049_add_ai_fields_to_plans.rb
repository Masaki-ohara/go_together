class AddAiFieldsToPlans < ActiveRecord::Migration[7.2]
  def change
    add_column :plans, :created_by, :string
    add_column :plans, :prompt, :text
  end
end
