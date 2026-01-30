class CreatePlans < ActiveRecord::Migration[7.2]
  def change
    create_table :plans do |t|
      t.date :date
      t.string :location
      t.integer :budget

      t.timestamps
    end
  end
end
