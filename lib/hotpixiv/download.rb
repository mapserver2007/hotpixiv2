# -*- coding: utf-8 -*-
require 'mechanize'
require 'open-uri'
require 'hotpixiv/runner'

module HotPixiv
  class Download
    # リクエストパラメータを作成
    def query(keyword, page)
      {:s_mode => "s_tag",
        :word => keyword,
        :p => page}.map {|k, v| "#{k.to_s}=#{CGI.escape(v.to_s.encode('UTF-8'))}"}.join("&")
    end

    # パラメータを整形
    def trim(data, i)
      return data.split(/\//)[4] if i == 6
      return "%02d" % data if i == 4 && i.to_s.length == 1
      data
    end

    # 文字列にダブルクオートが含まれている場合は置換する
    def esc(data)
      data.gsub(/\"\"\"/, "\"'").gsub(/\"\"/, "'")
    end

    def valiable_set(params)
      params.each do |k, v|
        self.instance_variable_set("@#{k.to_s}", v)
      end
    end

    # 画像URLを取得
    def get_url(data)
      point = POINT_BORDER
      e = []
      i = 0
      # 文字列にダブルクオートが含まれている場合は置換する
      esc(data).scan(/\"(.*?)\"/) do |d|
        e << trim(d[0], i)
        i += 1
      end
      # 総合点：e[16], 評価回数：e[15], 閲覧回数：e[17]
      # サーバID：e[4], ユーザID：e[6], 画像ID：e[0], 拡張子：e[2]
      url = "http://img#{e[4]}.pixiv.net/img/#{e[6]}/#{e[0]}.#{e[2]}"
      e[16].to_i >= point && URL_REGEXP =~ url ? url : nil
    end

    # 画像ダウンロード
    def download(list, keyword, &block)
      Runner.parallel(list) do |url|
        (download_from url, keyword).each do |res|
          block.call(res.keys.pop, res.values.pop)
        end
      end
    end

    # 画像をダウンロード
    def download_from(url, keyword)
      message_list = []
      begin
        save_image(url, keyword)
        message_list << {:info => url}
        # マンガの場合
        rescue OpenURI::HTTPError
          begin
            0.upto(Float::INFINITY) do |page|
              url_with_page = url.gsub(/(\d*)\.[jpg|png|gif]{3}/) do |matched|
                f = matched.split(/\./)
                "#{f[0]}_p#{page}.#{f[1]}"
              end
              save_image(url_with_page, keyword)
              message_list << {:info => url}
            end
          rescue OpenURI::HTTPError; end
        end
      message_list
    end

    # 画像を保存する
    def save_image(url, keyword)
      dir = Utils.create_path(@save_dir, keyword)
      open(url, "Referer" => REFERER) do |f|
        open(dir + "/" + File.basename(url), 'wb') do |output|
          output.write(f.read)
        end
      end
    end

    # ダウンロードを開始する
    def run(params, &block)
      valiable_set(params)
      agent = Mechanize.new
      agent.read_timeout = DOWNLOAD_TIMEOUT

      # ぺージ、キーワードのURLリストを作成
      page_list = []
      1.upto(@page.to_i) do |page_no|
        @keywords.each do |keyword|
          page_list << "#{PIXIV_API_URL}search.php?#{query(keyword, page_no)}"
        end
      end

      # 日付のディレクトリを作成
      raise "Invalid save directory path. - #{@save_dir}" unless Utils.directory?(@save_dir)
      @save_dir = Utils.create_path(@save_dir, DateTime.now.strftime("%Y%m%d"))
      Utils.create_dir(@save_dir)

      # 並列ダウンロード開始
      print "Downloading ... \n"
      Runner.parallel(page_list) do |page|
        # URLからキーワードを抽出
        keyword = URI.decode($1).encode(Utils.os_encoding) if /word=(.*?)&/ =~ page
        # キーワードのディレクトリを作成
        Utils.create_dir(@save_dir, keyword)
        url_list = []
        site = agent.get(page)
        lines = (site/ '//body/p').inner_html.split(/\n/)
        lines.each do |line|
          url_list << get_url(line)
        end
        # nilのデータを削除
        url_list.compact!
        # 画像をダウンロードする
        download(url_list, keyword, &block) unless url_list.empty?
      end
    end
  end
end