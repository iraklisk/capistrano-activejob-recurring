namespace :load do
  task :defaults do
    set :activejob_recurring_kill_signal, "KILL"
    set :activejob_recurring_log_file, '/dev/null'
    set :activejob_recurring_pid_path, -> { File.join(shared_path, 'tmp', 'pids') }
  end
end

namespace :activejob_recurring do
  def rails_env
      fetch(:rails_env) ||       # capistrano-rails doesn't automatically set this (yet),
      fetch(:stage)              # so we need to fall back to the stage.
  end

  def output_redirection
    ">> #{fetch(:activejob_recurring_log_file)} 2>> #{fetch(:activejob_recurring_log_file)}"
  end

  def create_pid_path
    if !(test "[ -d #{fetch(:activejob_recurring_pid_path)} ]")
      info "Creating #{fetch(:activejob_recurring_pid_path)}"
      execute :mkdir, "-p #{fetch(:activejob_recurring_pid_path)}"
    end
  end

  desc "See current activejob recurring scheduler status"
  task :status do
    on roles :activejob_recurring_scheduler do
      pid = "#{fetch(:activejob_recurring_pid_path)}/activejob_recurring_scheduler.pid"
      if test "[ -e #{pid} ]"
        info capture(:ps, "-f -p $(cat #{pid}) | sed -n 2p")
      end
    end
  end

  desc "Starts ActiveJob recurring scheduler with default configs"
  task :start do
    on roles :activejob_recurring_scheduler do
      create_pid_path
      pid = "#{fetch(:activejob_recurring_pid_path)}/activejob_recurring_scheduler.pid"
      within current_path do
        execute :nohup, %{#{SSHKit.config.command_map[:rake]} RACK_ENV=#{rails_env} RAILS_ENV=#{rails_env} PIDFILE=#{pid} BACKGROUND=yes MUTE=1 activejob:recurring:scheduler #{output_redirection}}
      end
    end
  end

  desc "Stops ActiveJob recurring scheduler"
  task :stop do
    on roles :activejob_recurring_scheduler do
      pid = "#{fetch(:activejob_recurring_pid_path)}/activejob_recurring_scheduler.pid"
      if test "[ -e #{pid} ]"
        execute :kill, "-s #{fetch(:activejob_recurring_kill_signal)} $(cat #{pid}); rm #{pid}"
      end
    end
  end

  desc "Restart ActiveJob recurring scheduler"
  task :restart do
    invoke "activejob_recurring:stop"
    invoke "activejob_recurring:start"
  end
end
