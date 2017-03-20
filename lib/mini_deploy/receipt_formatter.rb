
module MiniDeploy
  module ReceiptFormatter

    def format_default_task_value(old_task)
      new_task = { }
      new_task[:tag]     = old_task['tag'] || ''
      new_task[:process] = old_task['process'].to_sym
      new_task
    end

    def format_upload_file_task(old_task)
      return nil if old_task['upload_local_source'].nil? ||
                    old_task['remote_path'].nil?

      new_task = {}
      new_task[:upload_local_source] = old_task['upload_local_source']
      new_task[:remote_path]         = old_task['remote_path']
      new_task[:upload_mode]         = old_task['upload_mode'].to_s.downcase.to_sym
      new_task[:upload_mode]         = :text if new_task[:upload_mode] == :""
      new_task
    end

    def format_check_or_remove_file_task(old_task)
      return nil if old_task['remote_file'].nil?

      new_task = {}
      new_task[:remote_file] = old_task['remote_file']
      new_task
    end

    def format_send_http_request_task(old_task)
      return nil if ( old_task['url'].to_s =~ /https?:\/\// ).nil?

      new_task = {}
      new_task[:method] = old_task['method'].to_s.downcase.to_sym
      new_task[:method] = :get if new_task[:method] == :""
      new_task[:url]    = old_task['url']
      new_task[:params] = old_task['params'] || nil
      new_task
    end

    def format_find_file_content_task(old_task)
      return nil if old_task['remote_file'].nil?

      new_task = {}
      new_task[:ignore_case]    = old_task['ignore_case'] || false
      new_task[:search_content] = old_task['search_content'] || nil
      new_task[:remote_file]    = old_task['remote_file']
      new_task
    end

  end
end