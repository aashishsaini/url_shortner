namespace :cleanup do
  desc 'clean up old records which are not user'
  task :urls => :environment do
    ShortendUrl.unused_urls.delete_all
  end
end