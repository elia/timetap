require 'active_support/core_ext/hash/indifferent_access'

module TimeTap
  module Config
    attr_writer :config

    def config
      @config ||= {
        :root => "~",
        # root is where the logs will be saved

        # code is where all your projects live
        :code_folders => %w[
          ~/Code
          ~/Developer
          ~/Development
          ~/src
          ~/code
          ~/rails
          ~/Desktop
          ~
        ],

        :nested_project_layers => 1,
        # see below about nested projects

        :port => 1111,
        # the port on localhost for the web interface

        :ruby => '/usr/bin/ruby',
        # the ruby you want to use

        :backend         => :file_system,
        :backend_options => { :file_name => '~/.timetap.history' },
        :editor          => :text_mate,
        :log_file        => '~/.timetap.log'
      }.with_indifferent_access
    end

    def load_user_config!
      require 'yaml'
      TimeTap.config.merge! YAML.load_file(user_config) if File.exist?(user_config)
    end

    def user_config
      @user_config ||= File.expand_path('~/.timetap.config')
    end

    def install_config!
      puts 'Checking config...'
      unless File.exist? user_config
        require 'fileutils'
        example_config = File.expand_path('../time_tap/config.yml.example', __FILE__)
        FileUtils.copy example_config, user_config
        puts "Added default config to #{user_config}"
      end
    end

    def config= options = {}
      require 'active_support'

      # CONFIG
      @config = HashWithIndifferentAccess.new(options)
      @config[:root] = File.expand_path(config[:root])
      @config[:port] = config[:port].to_i
    end
  end
end
