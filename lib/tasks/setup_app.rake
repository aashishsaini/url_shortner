namespace :setup_app do
  desc 'setup the rails app in local machine'
  task :setup => :environment do
    sh "bundle"
    sh "rake db:drop"
    sh "rake db:create"
    sh "rake db:migrate"
    sh "rails server"
  end
end