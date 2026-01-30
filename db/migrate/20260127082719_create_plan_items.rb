class CreatePlanItems < ActiveRecord::Migration[7.2]
  def change
    create_table :plan_items do |t|
      t.references :plan, null: false, foreign_key: true
      t.string :content

      t.timestamps
    end
  end
end
