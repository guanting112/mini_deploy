require 'net/ftp'
require 'mini_deploy/temporary_file'

module MiniDeploy
  class ConnectFtp

    def initialize(host, username, password, passive_mode=false)
      @host            = host
      @username        = username
      @password        = password
      @passive_mode    = passive_mode
      @client          = Net::FTP.new(host)
      @connect_success = false
    end

    def connect_success?
      @connect_success
    end

    def connect
      @client.passive = true if @passive_mode
      @connect_success = @client.login @username, @password
    end

    def download_to_temp_file(remote_path, options={})
      temp_file = TemporaryFile.new
      happened_error = false

      @client.getbinaryfile(remote_path, temp_file.current_path)
    rescue Net::FTPPermError
      happened_error = true
    rescue StandardError
      happened_error = true
    ensure
      temp_file.destroy if happened_error

      return happened_error ? nil : temp_file
    end

    def upload(upload_local_source, remote_path, mode=:text)
      if mode == :text
        @client.put(upload_local_source, remote_path)
      else
        @client.putbinaryfile(upload_local_source, remote_path)
      end
    end

    def exists(remote_path)
      @client.size(remote_path)

      true
    rescue Net::FTPPermError => e
      false
    end

    def remove(remote_path)
      @client.delete(remote_path)

      true
    rescue Net::FTPPermError => e
      false
    end

    def list(arg='*')
      @client.list(arg)
    end

    def done
      @client.close
    end

  end
end