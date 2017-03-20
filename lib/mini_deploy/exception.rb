module MiniDeploy
  class Error < StandardError; end
  class HostsDataReaderLoadError < Error; end
  class ReceiptReaderLoadError < Error; end
  class ReceiptReaderParseError < Error; end
  class HostsDataNoMatchFound < Error; end
end