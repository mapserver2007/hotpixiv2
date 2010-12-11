# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/hotpixiv_helper.rb"

describe HotPixiv, 'が実行する処理' do
  before do
    @rspec = HotPixiv::Rspec.new
    @rspec.rewrite_download
    @rspec.add_log_inspector
    @params = @rspec.params.common
  end

  describe '正常系' do
    after do
      HotPixiv.log_inspector(:error, true).should be_nil
    end

    it "コマンドライン引数による実行が正常にできること" do
      HotPixiv.get(@params)
    end

    it "設定ファイルによる実行が正常にできること" do
      @params[:config] = @rspec.params.config
      HotPixiv.get(@params)
    end

    it "キーワードをコマンドライン引数から指定して正常に実行出来ること" do
      @params[:keyword] = "イカ娘"
      HotPixiv.get(@params)
    end

    it "キーワードをファイルから指定して正常に実行出来ること" do
      @params[:file_keyword] = @rspec.params.file_keyword
      HotPixiv.get(@params)
    end

    it "ファイルパス設定に日本語を含む場合、実行が正常にできること" do
      @params[:config] = @rspec.params.config_ja
      HotPixiv.get(@params)
    end
  end

  describe '異常系' do
    it "存在しないキーワードで検索した場合、画像が取得できないこと" do
      @params[:keyword] = @rspec.params.dummy_value
      HotPixiv.get(@params)
      @rspec.add_download_inspector(@params[:keyword])
    end

    it "ログ出力ディレクトリパスが間違っている場合「Invalid log directory path.」と表示されること" do
      @params[:log] = @rspec.params.dummy_value
      HotPixiv.get(@params)
      @rspec.error_inspector("Invalid log directory path - #{@params[:log]}")
    end

    it "画像保存ディレクトリパスが間違っている場合「No such file or direcotry - ディレクトリ名」と表示されること" do
      @params[:save_dir] = @rspec.params.dummy_value
      HotPixiv.get(@params)
      @rspec.error_inspector("Invalid save directory path. - #{@params[:save_dir] }")
    end

    it "設定ファイルのパスが間違っている場合「Config file not found.」と表示されること" do
      @params[:config] = @rspec.params.dummy_value
      HotPixiv.get(@params)
      @rspec.error_inspector("Config file not found.")
    end
  end
end