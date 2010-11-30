require 'rspec'
require File.dirname(__FILE__) + "/../lib/hotpixiv"
require File.dirname(__FILE__) + "/../lib/hotpixiv/download"
require File.dirname(__FILE__) + "/../lib/hotpixiv/utils"

module HotPixiv
  class Rspec
    def method_missing(name, *args)
      attr = name.to_s
      if @attr == "params"
        config = Utils.load(File.dirname(__FILE__) + "/spec_config.yml")
        @attr = nil
        if attr == "common" || attr == "other"
          config[attr.to_sym].inject({}){|r, entry| r[entry[0].to_sym] = entry[1]; r}
        else
          config[:common][attr] || config[:other][attr]
        end
      elsif attr == "params"
        @attr = attr
        self
      end
    end

    # テスト用に画像を1件のみ取得するようにメソッドを書き換える
    def rewrite_download
      HotPixiv::Download.class_eval do
        def download(list, keyword, &block)
          test_list = [list[0]]
          Runner.parallel(test_list) do |url|
            (download_from url, keyword).each do |res|
              block.call(res.keys.pop, res.values.pop)
            end
          end
        end
      end
    end

    # ダウンロード処理の実行結果を監視するメソッドを動的に定義
    def add_download_inspector(keyword)
      dir = Utils.create_path(self.params.save_dir,
        DateTime.now.strftime("%Y%m%d"), keyword)
      dir = Dir::entries(dir).reject! {|e| e == "." || e == ".."}
      dir.should be_empty
    end

    # ログ処理の実行結果を監視するメソッドを動的に定義
    def add_log_inspector
      Log.class_eval do
        def ignore_error(list)
          # ネットワークエラーは状況によって発生するのでテストでは無視する
          ignores = ["getaddrinfo: no address associated with hostname."]
          list.reject! do |e|
            ignores.index(e) != nil
          end unless list.nil?
        end

        def log_inspector(level, error_ignore)
          # 特定のエラーを無視する
          if error_ignore
            ignore_error @debug[level]
          end
          @debug[level]
        end
      end

      class << HotPixiv
        def log_inspector(level, error_ignore = false)
          @log.log_inspector(level.to_s, error_ignore)
        end
      end
    end

    # 実行結果エラーログを確認する
    def error_inspector(msg)
      HotPixiv.log_inspector(:error).each do |inspect_msg|
        inspect_msg.should == msg
      end
    end
  end
end