require 'http'

module MiniDeploy
  class Processor
    def initialize(console, original_script, host_data, receipt_data)
      @console      = console
      @script       = marshal_copy(original_script)
      @host_data    = host_data
      @receipt_data = receipt_data
      @ftp          = nil

      create_ftp_client_connect if needs_to_create_ftp
    end

    def script_tag
      @script[:tag]
    end

    def script_type
      @script[:process]
    end

    def upload_file
      @console.log "Upload file to remote server"

      format_script_data(:upload_local_source, :remote_path)

      @console.log "Uploading #{@script[:upload_local_source]} "
      @console.log "to #{@script[:remote_path]} "

      upload_file_content =
        replace_data(IO.read(@script[:upload_local_source]), @host_data[:info])

      temp_file = TemporaryFile.new
      temp_file.write upload_file_content

      @ftp.upload(temp_file.current_path, @script[:remote_path])

      @console.done "Upload Successful"

      temp_file.done
      @ftp.done
    rescue StandardError => e
      @console.error e.message
    end

    def find_file_content
      @console.log "Find file on remote server"

      format_script_data(:remote_file)

      @console.log "Search \"#{@script[:remote_file]}\" content"

      temp_file = @ftp.download_to_temp_file(@script[:remote_file])
      file_exists = temp_file.nil? != true

      if file_exists
        @console.done "File is found"
        match_content = find_file_content_by_io(temp_file.current_path, filter: @script[:search_content], ignore_case: @script[:ignore_case])

        if match_content.nil?
          @console.error "No match content"
        else
          @console.data match_content
        end
      else
        @console.error "File not found"
      end

      @ftp.done
    rescue StandardError => e
      @console.error e.message
    end

    def check_file
      @console.log "Check file on remote server"

      format_script_data(:remote_file)

      @console.log "Check \"#{@script[:remote_file]}\""

      if @ftp.exists(@script[:remote_file])
        @console.done "File is found"
      else
        @console.error "File not found"
      end

      @ftp.done
    rescue StandardError => e
      @console.error "Unable to connect to the remote server"
      @console.error e.message
    end


    def remove_file
      @console.log "Remove file on remote server"

      format_script_data(:remote_file)

      @console.log "Remove \"#{@script[:remote_file]}\""

      if @ftp.remove(@script[:remote_file])
        @console.done "File is removed."
      else
        @console.error "File not found or Can't removed"
      end

      @ftp.done
    rescue StandardError => e
      @console.error "Unable to connect to the remote server"
      @console.error e.message
    end


    def send_http_request
      @console.log "Sent http request to remote server"

      format_script_data(:url)

      @console.log "url: #{@script[:url]}"

      if @script[:params].is_a? Hash
        @script[:params].each do |key, value|
          if value.is_a? String
            @script[:params][key] = replace_data(value, @host_data[:info])
          end
        end
      end

      http_client = HTTP.headers('user-agent' => @receipt_data[:agent_name])

      case @script[:method]
      when :get
        @console.data http_client.get(@script[:url], params: @script[:params]).body.to_s
      when :post
        @console.data http_client.post(@script[:url], form: @script[:params]).body.to_s
      else
        @console.error "Unknown http method"
      end

    rescue StandardError => e
      @console.error "Unable to connect to the remote server"
      @console.error e.message
    end

    private

      def format_script_data(*keys)
        keys.each do |key|
          @script[key] = replace_data(@script[key], @host_data[:info])
        end
      end

      def create_ftp_client_connect
        @ftp = ConnectFtp.new(@host_data[:host], @host_data[:ftp_username], @host_data[:ftp_password], @host_data[:ftp_passive_mode])

        @ftp.connect
      end

      def needs_to_create_ftp
        [
          :upload_file,
          :find_file_content,
          :check_file,
          :remove_file
        ].include?(script_type)
      end

      def marshal_copy(object)
        Marshal.load(Marshal.dump(object))
      end

      def replace_data(data, info=nil)
        return data if info.nil?
        
        info.each do |key, value|
          data.gsub!("[info.#{key}]", value)
        end

        data
      end

      def find_file_content_by_io(file_path, options={})
        result = nil

        needs_to_filter_data = !options[:filter].nil?

        if needs_to_filter_data
          match_lines      = []

          if options[:ignore_case]
            search_condition = Regexp.new(options[:filter], Regexp::IGNORECASE)
          else
            search_condition = Regexp.new(options[:filter])
          end

          data = IO.readlines(file_path)

          data.each do |line|
            match_lines.push line if line =~ search_condition
          end

          result = match_lines.join
          result = nil if result.length == 0
        else
          result = IO.read(file_path)
        end
        
        result
      end

  end
end