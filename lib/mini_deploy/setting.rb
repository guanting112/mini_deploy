module MiniDeploy
  module Setting

    @data_storage = {}

    def self.all
      @data_storage
    end

    def self.[](key)
      all[key]
    end

    def self.[]=(key, value)
      all[key] = value
    end

  end

  Setting[:receipt_file_path] = ''
  Setting[:host_file_path]    = ''
end
