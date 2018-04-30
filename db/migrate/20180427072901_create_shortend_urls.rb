class CreateShortendUrls < ActiveRecord::Migration
  def change
    create_table :shortend_urls do |t|
      t.text :original_url
      t.string :short_url
      t.string :sanitize_url
      t.text :page_title
      t.integer :hits, default: 0
      t.integer :creator_id

      t.timestamps null: false
    end
  end
end
