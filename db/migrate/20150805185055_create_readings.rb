class CreateReadings < ActiveRecord::Migration
  def change
    create_table :readings do |t|
      t.integer :glucose_level,:user_id
      t.timestamps null: false
    end
  end
end
