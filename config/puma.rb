# config/puma.rb

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

# Specify the rackup file explicitly
rackup      'config.ru'
port        ENV['PORT'] || 8778
environment ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'production'

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

