require 'logger'
require 'pathname'

module HotPixiv
  module Utils
    class << self
      def read_text(path)
        data = []
        if file?(path)
          open(path) do |f|
            while line = f.gets do
              data << line.chomp unless line.chomp.empty?
            end
          end
        end
        data
      end

      def file?(e)
        !!(FileTest.exist?(e) rescue nil)
      end

      def directory?(e)
        !!(FileTest::directory?(e) rescue nil)
      end

      def create_path(*args)
        Pathname.new(args.join("/")).cleanpath.to_s.encode(Utils.os_encoding)
      end

      def create_dir(*args)
        Dir::mkdir(create_path(args)) rescue nil
      end

      def load(path)
        config = YAML.load_file(path)
        config.inject({}){|r, entry| r[entry[0].to_sym] = entry[1]; r}
      end

      def os_encoding
        RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ ?
          "Windows-31J" : "UTF-8"
      end
    end
  end

  class Log
    def initialize(path, debug_on)
      @debug = {}
      @debug_on = debug_on
      if Utils.directory? path
        level = [0, 1, 2, 3, 4].index(LOG_LEVEL) || Logger::DEBUG
        @log = Logger.new(logfile(path))
        @log.level = level
      else
        unless path.nil?
          @debug["error"] = []
          @debug["error"] << "Invalid log directory path - #{path}"
        end
      end
    end

    def logfile(dir)
      Pathname.new(dir + "/" + "#{Time.now.strftime("%Y%m%d")}.log").cleanpath
    end

    def write(name, *args)
      # ログ出力処理、デバッグスタックに保存
      if name =~ /=$/
        name.chop!
        @debug[name] = [] unless @debug[name].instance_of?(Array)
        args[0].each do |msg|
          @log.send(name, msg.encode(Utils.os_encoding)) unless @log.nil?
          @debug[name] << msg
        end
      end
    end

    def debug(name)
      # デバッグメッセージを標準出力
      if name == 'print'
        @debug[@name].each do |msg|
          puts msg
        end if @debug[@name].instance_of?(Array) && @debug_on
      else
         # ログメソッドを保存
        @name = name
        self
      end
    end

    def method_missing(name, *args)
      attr = name.to_s
      write(attr, args)
      debug(attr)
    end
  end
end