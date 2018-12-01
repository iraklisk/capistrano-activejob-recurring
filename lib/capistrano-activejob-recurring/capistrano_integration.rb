require "capistrano"
require "capistrano/version"

module CapistranoResque
  class CapistranoIntegration
    def self.load_into(capistrano_config)
      capistrano_config.load do

        _cset(:activejob_recurring_kill_signal, "KILL")
        _cset(:activejob_recurring_log_file, "/dev/null")
        _cset(:activejob_recurring_pid_path) { File.join(shared_path, 'tmp', 'pids') }

        def rails_env
          fetch(:rails_env, "production")
        end

        def output_redirection
          ">> #{fetch(:activejob_recurring_log_file)} 2>> #{fetch(:activejob_recurring_log_file)}"
        end

        def status_scheduler
          "if [ -e #{fetch(:activejob_recurring_pid_path)}/activejob_recurring_scheduler.pid ]; then \
             ps -p $(cat #{fetch(:resque_pid_path)}/activejob_recurring_scheduler.pid) | sed -n 2p \
           ;fi"
        end

        def start_scheduler(pid)
          "cd #{current_path} && RACK_ENV=#{rails_env} RAILS_ENV=#{rails_env} \
           nohup #{fetch(:bundle_cmd, "bundle")} exec rake \
           activejob:recurring:scheduler #{output_redirection} \
           & echo $! > #{pid}"
        end

        def stop_scheduler(pid)
          "if [ -e #{pid} ]; then \
            kill -s #{active_job_recurring_kill_signal} $(cat #{pid}) ; rm #{pid} \
           ;fi"
        end

        def create_pid_path
          "if [ ! -d #{fetch(:activejob_recurring_pid_path)} ]; then \
            echo 'Creating #{fetch(:activejob_recurring_pid_path)}' \
            && mkdir -p #{fetch(:active_job_recurring_pid_path)}\
          ;fi"
        end

        namespace :activejob_recurring do
          desc "See current scheduler status"
          task :status, :roles => :activejob_recurring_scheduler do
            run(status_scheduler)
          end

          desc "Starts ActiveJob recurring scheduler with default configs"
          task :start, :roles => :activejob_recurring_scheduler do
            run(create_pid_path)
            pid = "#{fetch(:activejob_recurring_pid_path)}/activejob_recurring_scheduler.pid"
            run(start_scheduler(pid))
          end

          desc "Stops ActiveJob recurring scheduler"
          task :stop, :roles => :activejob_recurring_scheduler do
            pid = "#{fetch(:activejob_recurring_pid_path)}/activejob_recurring_scheduler.pid"
            run(stop_scheduler(pid))
          end

          desc "Restarts ActiveJob recurring scheduler"
          task :restart do
            stop
            start
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  CapistranoResque::CapistranoIntegration.load_into(Capistrano::Configuration.instance)
end
