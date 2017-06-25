class CreateEventsbases < ActiveRecord::Migration[5.0]
  def change
    create_table :eventsbases do |t|
      t.string :data

      t.timestamps
    end
  end
end
