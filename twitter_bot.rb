#!/usr/bin/env ruby
# coding: utf-8

require 'rubygems'
require 'oauth'
require 'json'
require 'hpricot'
require 'open-uri'
require 'yaml'
require 'parsedate'
require 'kconv'
require File.dirname(__FILE__) + '/twitter_oauth'

# Usage:
#  1. このファイルと同じディレクトリに以下5つのファイルを設置します。
#   * twitter.rb
#    * http://github.com/japanrock/TwitterTools/blob/master/twitter_oauth.rb
#   * sercret_key.yml 
#    * http://github.com/japanrock/TwitterTools/blob/master/secret_keys.yml.example
#  2. このファイルを実行します。
#   ruby twitter_bot.rb

class LrCulture
  attr_reader :selected_culture
  attr_reader :select

  def initialize
    # カレントディレクトリの culture.yml をロードします
    @culture = YAML.load_file(File.dirname(__FILE__) + '/culture.yml')
  end

  def head
    ""
  end

  def random_select
    @selected_culture = @culture[select]
  end

  # ポストする範囲を指定する
  def select
    @select = rand(80)
  end
end

twitter_oauth = TwitterOauth.new
#lr_culture    = LrCulture.new

#content  = lr_culture.random_select
#head     = lr_culture.head
#url      = lr_culture.selected_culture["url"]
#contents = lr_culture.selected_culture["contents"]

twitter_oauth.post("Test")
