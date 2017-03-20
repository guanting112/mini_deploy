require 'yaml'
require 'mini_deploy/receipt_formatter'

module MiniDeploy
  class ReceiptReader
    include MiniDeploy::ReceiptFormatter

    def initialize(receipt_file_path)
      @receipt_file_path = receipt_file_path

      @receipt = nil
    end

    def fetch
      format(read_receipt)
    end

    def format(receipt_data)
      new_data = {
        is_valid: false,
        deploy_nodes: receipt_data.fetch('deploy_nodes'),
        receipt_title: receipt_data.fetch('title') { 'Untitled Receipt' },
        receipt_create_at: receipt_data.fetch('date') { 'No Data' },
        receipt_author: receipt_data.fetch('author') { 'No Author Name '},
        receipt_tasks: nil,
        agent_name: receipt_data.fetch('agent_name') { "MiniDeploy/#{MiniDeploy::VERSION}" },
        time: Time.now.utc
      }

      new_data[:receipt_tasks] = format_tasks(receipt_data['tasks'])

      new_data
    rescue StandardError
      raise ReceiptReaderParseError
    end

    def format_tasks(tasks_data)
      [] unless tasks_data.is_a?(Array)

      tasks_data.map! do |task|
        format_task(task)
      end

      tasks_data.compact
    end

    def format_task(old_task)
      new_task = format_default_task_value(old_task)
      new_option = nil

      case new_task[:process]
      when :check_file
        new_option = format_check_or_remove_file_task(old_task)
      when :send_http_request
        new_option = format_send_http_request_task(old_task)
      when :remove_file
        new_option = format_check_or_remove_file_task(old_task)
      when :upload_file
        new_option = format_upload_file_task(old_task)
      when :find_file_content
        new_option = format_find_file_content_task(old_task)
      else
        new_option = nil
      end

      if new_option.is_a?(Hash)
        new_task.merge(new_option) 
      else
        nil
      end
    end

    def read_receipt
      YAML.load(IO.read(@receipt_file_path))
    rescue StandardError
      raise ReceiptReaderLoadError
    end

  end
end