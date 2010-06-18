#!/usr/bin/env ruby
# coding: utf-8

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/htmlentities-4.2.0/lib/')
require 'rubygems'
require 'json'
require 'hpricot'
require 'open-uri'
require 'yaml'
require 'parsedate'
require 'kconv'
require 'htmlentities'
require File.dirname(__FILE__) + '/twitter_oauth'
require File.dirname(__FILE__) + '/tweet_history'

# Usage:
#  1. このファイルと同じディレクトリに以下5つのファイルを設置します。
#   * twitter_oauth.rb
#    * http://github.com/japanrock/TwitterTools/blob/master/twitter_oauth.rb
#   * tweet_history.rb
#    * http://github.com/japanrock/TwitterTools/blob/master/twieet_history.rb
#   * sercret_key.yml 
#    * http://github.com/japanrock/TwitterTools/blob/master/secret_keys.yml.example
#  2. このファイルを実行します。
#   ruby twitter_bot.rb

# See:
# http://d.hatena.ne.jp/japanrock_pg/20100617/1276780421

class Array
  def choice
   at( rand( size ) )
  end
end

class Janken
  attr_reader :all_screen_name
  attr_reader :all_status_id
  attr_reader :all_text
  
  def initialize
    @twitter_oauth = TwitterOauth.new
    @all_screen_name = []
    @all_status_id = []
    @all_text = []
  end

  def mentions
    @twitter_oauth.get_mentions
  end

  # フィードをHpricotのオブジェクトにします。
  def open_feed
    Hpricot(mentions)
  end

  def feed
    (open_feed.search("screen_name")).each do |elems|
      screen_name = HTMLEntities.new.decode(elems.inner_html)
      @all_screen_name << screen_name
    end

    (open_feed.search("status/id")).each do |elems|
      @all_status_id << elems.inner_html
    end

    (open_feed.search("text")).each do |elems|
      text = HTMLEntities.new.decode(elems.inner_html)
      @all_text << text
    end
  end

  def game(text, screen_name)
    return nil unless text && screen_name
   
    case text
    when /RT|QT/
      result = nil
    when /グー|ぐー|rock/
      result = game_rock(screen_name)
    when /チョキ|ちょき|scissors/
      result = game_scissors(screen_name)
    when /パー|ぱー|paper/
      result = game_paper(screen_name)
    else
      result = nil
    end

    result
  end

  def post(tweet = nil)
    @twitter_oauth.post(tweet + " - " + @twitter_oauth.countermeasure_duplicate) if tweet 
  end

  def post_success?
    @twitter_oauth.response_success?
  end

  private

  def game_rock(screen_name)
    [
     "@#{screen_name} あいこ（あなた => グー、 _janken => グー）",
     "@#{screen_name} あなたの勝利（あなた => グー、 _janken => チョキ）",
     "@#{screen_name} あなたの負け（あなた => グー、 _janken => パー）"
    ].choice
  end

  def game_scissors(screen_name)
    [
     "@#{screen_name} あいこ（あなた => チョキ、 _janken => チョキ）",
     "@#{screen_name} あなたの勝利（あなた => チョキ、 _janken => パー）",
     "@#{screen_name} あなたの負け（あなた => チョキ、 _janken => グー）"
    ].choice
  end

  def game_paper(screen_name)
    [
     "@#{screen_name} あいこ（あなた => パー、 _janken => パー）",
     "@#{screen_name} あなたの勝利（あなた => パー、 _janken => グー）",
     "@#{screen_name} あなたの負け（あなた => パー、 _janken => チョキ）"
    ].choice
  end
end

# main

tweet_history = TweetHistory.new
janken = Janken.new
janken.feed

janken.all_status_id.each_with_index do |status_id, index|
  unless tweet_history.past_in_the_tweet?(status_id)
    screen_name = janken.all_screen_name[index]
    text        = janken.all_text[index]

    result = janken.game(text, screen_name)
    janken.post(result) if result
    tweet_history.write(status_id) if janken.post_success?
  end
end

# tweet_historyファイルの肥大化防止
tweet_history.maintenance

