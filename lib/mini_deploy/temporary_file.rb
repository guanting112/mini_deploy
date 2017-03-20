require 'tempfile'

module MiniDeploy
  class TemporaryFile
    def initialize
      @tempfile = Tempfile.new('mwd')
    end

    def write(data)
      @tempfile.write data
      @tempfile.rewind
    end

    def close
      @tempfile.close
    end

    def destroy
      @tempfile.unlink
    end

    def done
      close
      destroy
    rescue StandardError => e
      # ignore
    end

    def current_path
      @tempfile.path
    end
  end
end
