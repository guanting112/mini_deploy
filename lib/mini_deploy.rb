require 'mini_deploy/version'
require 'mini_deploy/hosts_data_reader'
require 'mini_deploy/receipt_reader'
require 'mini_deploy/connect_ftp'
require 'mini_deploy/cli'
require 'mini_deploy/processor'
require 'mini_deploy/sample_file'
require 'pretty_console_output'
require 'json'
require 'readline'

module MiniDeploy
  class TasksRunner
    def initialize
      console_tag "Load Important File"
      console.info "Load host and receipt file."

      @receipt_data =
        ReceiptReader.new(Setting[:receipt_file_path]).fetch

      @chose_hosts = @receipt_data[:deploy_nodes]

      @hosts_data =
        HostsDataReader.new(Setting[:host_file_path]).fetch

      @hosts_data.select! do |item|
        @chose_hosts.include?(item[:node_id])
      end

      raise HostsDataNoMatchFound if @hosts_data.length < 1

      console.done 'Loaded.'

    rescue HostsDataNoMatchFound
      show_important_error "Hosts Data No Match Found"

    rescue HostsDataReaderLoadError
      show_important_error "Can't load hosts file."

    rescue ReceiptReaderLoadError
      show_important_error "Can't load receipt hosts file."

    rescue ReceiptReaderParseError
      show_important_error "Can't parse receipt hosts file."
    end

    def start
      console_tag 'Start Receipt Script'
      console.done "Load Receipt: #{@receipt_data[:receipt_title]} ( by #{@receipt_data[:receipt_author]}, #{@receipt_data[:receipt_create_at]} )"

      show_chose_hosts

      console_tag "Confirm execute."
      show_important_error "User stop task." unless confirmed_start

      @hosts_data.each do |host_data|
        process_host_task host_data
      end

      console_tag "All Done"
      console.done "Receipt processed: " + Time.now.to_s

    rescue StandardError => e
      show_important_error e.message
    end

    private

      def process_host_task(host_data)
        console_tag "Connect #{host_data[:host]} ( #{host_data[:node_id]} )"

        @receipt_data[:receipt_tasks].each do |original_script|
          processor = Processor.new(console, original_script, host_data, @receipt_data)

          console.info "Process Task: #{processor.script_tag}"

          case processor.script_type
          when :check_file
            processor.check_file
          when :remove_file
            processor.remove_file
          when :find_file_content
            processor.find_file_content
          when :send_http_request
            processor.send_http_request
          when :upload_file
            processor.upload_file
          else
            console.error "Ignore unknown task"
          end
        end
      end

      def console
        @console ||= PrettyConsoleOutput::Console.new(theme: { tag_underscore: false })
      end

      def console_tag(tag_message)
        console.tag "#{tag_message} →"
      end

      def show_important_error(message)
        console_tag 'Error happened'
        console.error message
        exit
      end

      def confirmed_start
        user_input = Readline.readline("yes or no ? ( y/n/ok ) ", true)
        user_input.downcase!

        [ 'yes', 'y', 'ok' ].include?(user_input)
      rescue Interrupt
        false
      end

      def show_chose_hosts
        console_tag 'Servers'

        @hosts_data.each do |host|
          console.log "* #{host[:node_id]} - #{host[:host]}"
        end
      end

  end
end
