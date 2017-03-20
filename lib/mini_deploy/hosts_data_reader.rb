require 'yaml'
require 'mini_deploy/setting'
require 'mini_deploy/exception'

module MiniDeploy
  class HostsDataReader

    def initialize(host_file_path)
      @host_file_path = host_file_path
    end

    def fetch
      read_host_data.map { |host_data| format_host_data(host_data) }
    end

    def format_host_data(host_data)
      {
        node_id: host_data.fetch('node_id'),
        host: host_data.fetch('host'),
        ftp_username: host_data.fetch('ftp_username'),
        ftp_password: host_data.fetch('ftp_password'),
        ftp_passive_mode: host_data.fetch('ftp_passive_mode') { false },
        info: host_data.fetch('info') { nil },
        time: Time.now.utc
      }
    end

    def read_host_data
      YAML.load(IO.read(@host_file_path))
    rescue StandardError
      raise HostsDataReaderLoadError
    end

  end
end