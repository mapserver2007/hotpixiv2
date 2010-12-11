# -*- coding: utf-8 -*-
require 'hotpixiv/download'
require 'hotpixiv/utils'

module HotPixiv
  VERSION = '0.2.1'
  PIXIV_API_URL = 'http://iphone.pxv.jp/iphone/'
  REFERER = 'http://www.pixiv.net/'
  USER_AGENT = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us)
    AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16'
  DOWNLOAD_TIMEOUT = 10
  PAGE = 20
  POINT_BORDER = 30
  LOG_LEVEL = 1
  URL_REGEXP = /s?http?:\/\/img\d{2}.pixiv.net\/img\/.*?\/\d{8}\.(jpg|gif|png)/

  class << self
    # 共通設定
    def init(params)
      begin
        params.merge!(Utils.load(params[:config]))
      rescue
        unless params[:config].nil? || Utils.file?(params[:config])
          raise "Config file not found."
        end
      ensure
        @log = Log.new(params[:log], params[:debug])
      end
      params[:point_border] ||= POINT_BORDER
      keywords = Utils.read_text(params[:file_keyword])
      keywords << params[:keyword] if keywords.length == 0
      params[:keywords] = keywords
    end

    # 画像を取得する
    def get(params)
      begin
        # 基本設定
        init(params)
        # 画像のダウンロード
        Download.new.run(params) do |level, msg|
          # 処理が成功した場合
          if level == :info
            @log.info = msg
            print "o"
          # 処理が失敗した場合
          elsif level == :error
            @log.error = msg
            print "x"
          end
        end
      rescue => e
        @log.error = e.message
      end
      # エラーがあった場合は出力
      @log.error.print
    end
  end
end