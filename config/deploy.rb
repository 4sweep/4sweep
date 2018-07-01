# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'foursweep'
set :repo_url, 'REPLACE_ME'
#
# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'
#
# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

set :tmp_dir, 'REPLACE_ME'

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc "Restart nginx"
  task :restart do
    on roles(:all) do
      execute "#{deploy_to}/bin/restart"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

task :notify_rollbar do
  on roles(:app) do |h|
    revision = `git log -n 1 --pretty=format:"%H"`
    local_user = `whoami`
    rollbar_token = 'REPLACE_ME'
    rails_env = fetch(:rails_env, 'production')
    # execute "curl -s https://api.rollbar.com/api/1/deploy/ -F access_token=#{rollbar_token} -F environment=#{rails_env} -F revision=#{revision} -F local_username=#{local_user} >/dev/null 2>&1", :once => true
  end
end

# after :deploy, 'notify_rollbar'


