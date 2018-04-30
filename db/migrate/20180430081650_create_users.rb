class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.text :address
      t.string :city
      t.string :state
      t.string :state_code
      t.string :country
      t.string :country_code
      t.string :postal_code
      t.string :metro_code
      t.string :ip
      t.string :coordinates
      t.decimal :latitude, precision: 10 , scale: 6
      t.decimal :longitude, precision: 10 , scale: 6
      t.string :province
      t.string :province_code
      t.string :browser

      t.timestamps null: false
    end
  end
end
