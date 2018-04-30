class UsersShortendUrls < ActiveRecord::Migration
  def change
    create_table :shortend_urls_users do |t|
      t.references :shortend_url
      t.references :user
    end
  end
end
