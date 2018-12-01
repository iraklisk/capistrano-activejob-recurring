# Capistrano ActiveJob Recurring


### In your Gemfile:

```ruby
gem "capistrano-resque", "~> 0.2.2", require: false
```

### In lib/tasks:

You'll need to make sure your app is set to include Resque's rake tasks. Per the
[Resque 1.x README](https://github.com/resque/resque/blob/1-x-stable/README.markdown#in-a-rails-3-app-as-a-gem),
you'll need to add `require 'resque/tasks'` somewhere under the `lib/tasks` directory (e.g. in a `lib/tasks/resque.rake` file).

### In your Capfile:

Put this line __after__ any of capistrano's own `require`/`load` statements (specifically `load 'deploy'` for Cap v2):

```ruby
require "capistrano-activejob-recurring"
```

Note: You must tell Bundler not to automatically require the file (by using `require: false`),
otherwise the gem will try to load the Capistrano tasks outside of the context of running
the `cap` command (e.g. running `rails console`).

### In your deploy.rb:

```ruby
# Specify the server that ActiveJob recurring will be deployed on. If you are using Cap v3
# and have multiple stages with different ActiveJob recurring requirements for each, then
# these __must__ be set inside of the applicable config/deploy/... stage files
# instead of config/deploy.rb:
role :activejob_recurring_scheduler, "app_domain"


# We default to storing PID files in a tmp/pids folder in your shared path, but
# you can customize it here (make sure to use a full path). The path will be
# created before starting the scheduler if it doesn't already exist.
# set :activejon_recurring_pid_path, -> { File.join(shared_path, 'tmp', 'pids') }
```


### License

Please see the included LICENSE file.
