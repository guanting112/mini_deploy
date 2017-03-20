require 'thor'
require 'mini_deploy'
require 'fileutils'

module MiniDeploy
  class Cli < Thor

    desc 'start RECEIPT_FILE --host HOST_FILE', 'Start Task'
    method_option :host, :type => :string
    def start(path)
      Setting[:receipt_file_path] = File.expand_path(path)
      Setting[:host_file_path]    = File.expand_path(options[:host])

      if options[:host].nil?
        puts "Host File Not Found "
      else
        start_tasks_runner
      end
    end

    desc 'version', 'Prints version'
    def version
      puts VERSION
    end

    desc 'install', 'Create sample config and receipt file '
    def install
      puts "Create sample config and receipt file. "

      sample_file = SampleFile.new

      [ './config/', './receipts/' ].each do |dir_path|
        if Dir.exist?(dir_path)
          puts "* #{dir_path} exists."
        else
          FileUtils.mkdir_p(dir_path)
          puts "* #{dir_path} created."
        end
      end

      sample_hosts_default_path = './config/sample_hosts.yml'

      IO.write(sample_hosts_default_path, sample_file.hosts)
      puts "* #{sample_hosts_default_path} create."

      sample_receipt_default_path = './receipts/sample.yml'

      IO.write(sample_receipt_default_path, sample_file.receipt)
      puts "* #{sample_receipt_default_path} create."
    end

    private 

      def start_tasks_runner
        MiniDeploy::TasksRunner.new.start
      end
  end
end