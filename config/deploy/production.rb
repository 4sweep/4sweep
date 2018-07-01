# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
role :app, %w{REPLACE_ME}
role :web, %w{REPLACE_ME}
role :db,  %w{REPLACE_ME}


set :deploy_to, "REPLACE_ME"
set :linked_dirs, %w{log tmp}
set :delayed_job_args, "-n 2"
set :branch, "master"
set :rails_env, "production"

set :default_env, {
 'GEM_PATH' => 'REPLACE_ME/gems/',
 'GEM_HOME' => 'REPLACE_ME/gems/',
}

namespace :delayed_job do

  def args
    fetch(:delayed_job_args, "")
  end

  def delayed_job_roles
    fetch(:delayed_job_server_role, :app)
  end

  desc 'Stop the delayed_job process'
  task :stop do
    on roles(delayed_job_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'script/delayed_job', :stop
        end
      end
    end
  end

  desc 'Start the delayed_job process'
  task :start do
    on roles(delayed_job_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'script/delayed_job', args, :start
        end
      end
    end
  end

  desc 'Restart the delayed_job process'
  task :restart do
    on roles(delayed_job_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :'script/delayed_job', :stop
          execute :bundle, :exec, :'script/delayed_job', args, :restart
        end
      end
    end
  end

end

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'delayed_job:restart'
  end
end
