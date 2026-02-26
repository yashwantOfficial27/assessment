class CreateWeathers < ActiveRecord::Migration[7.2]
  def change
    create_table :weathers do |t|
      t.decimal :lat, precision: 10, scale: 4
      t.decimal :lon, precision: 10, scale: 4
      t.string :city
      t.string :state
      t.json :temperatures

      t.timestamps
    end
  end
end
