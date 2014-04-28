class MatchesController < ApplicationController
  require 'open-uri'

  def index
    match_list_url = 'http://info.sporttery.cn/football/match_list.php'
    @match_list = parse_main(match_list_url)
    @match_score_list = []

    i = 0
    @match_list.each do |one_match|
      pool_no = parse_link_no(one_match[4]) unless one_match[4].nil?
      remote_pool_url = "http://info.sporttery.cn/football/pool_result.php?id=#{pool_no}"
      match_score = parse_pool(remote_pool_url) << pool_no
      @match_score_list << match_score
      @match_list[i] += match_score
      i += 1

    # @match_score_list << Array(pool_no)
    # one_match += parse_pool_efg(remote_pool_url)
    # parse_pool remote_pool_url
    # local_pool_url = "data/#{pool_no}.html"
    # fetch_page remote_pool_url, local_pool_url
    # puts "#{pool_no} downloaed."
    # parse_pool local_pool_url
    end
  end

  private

  def parse_td(tr_link, td_tag)
    content = nil
    tr_link.css(td_tag).each do |td_link|
      content = td_link.content
    end
    content
  end

  def parse_link(tr_link, td_tag)
    content = nil
    tr_link.css(td_tag).each do |td_link|
      content = td_link['href']
    end
    content
  end

  def parse_link_no full_link
    pattern = /\?m=/
      ret = pattern.match(full_link)
    ret.post_match
  end

  def parse_main url
    match_list = []
    count = 0
    doc = Nokogiri::HTML(open(url))
    doc.css('tr').each do |tr_link|  
      count += 1
      one_match = []
      one_match[0] = parse_td(tr_link, 'td:nth-child(1)')
      one_match[1] = parse_td(tr_link, 'td:nth-child(2)')
      one_match[2] = parse_td(tr_link, 'td:nth-child(4)')
      one_match[3] = parse_td(tr_link, 'td:nth-child(3) a')
      one_match[4] = parse_link(tr_link, 'td:nth-child(3) a')
      one_match.compact!
      match_list << one_match if one_match.size == 5
    end
    match_list
  end

  def calculate first_val, last_val
    (first_val.to_f - last_val.to_f) / last_val.to_f
  end

  def parse_pool_efg doc
    vals = []

  # doc = Nokogiri::HTML(open(url))
    giri_table = doc.css('table')[2]
    giri_tr_first = giri_table.css('tr:nth-child(3)')
    giri_tr_last = giri_table.css('tr:last-child')

    td_e_first = giri_tr_first.css('td:nth-child(2)').first
    td_e_last = giri_tr_last.css('td:nth-child(2)').first
    (val_e = calculate(td_e_first.content, td_e_last.content)) unless (td_e_first.nil? or td_e_last.nil?)
    vals << val_e

    td_f_first = giri_tr_first.css('td:nth-child(3)').first
    td_f_last = giri_tr_last.css('td:nth-child(3)').first
    (val_f = calculate(td_f_first.content, td_f_last.content)) unless (td_f_first.nil? or td_f_last.nil?)
    vals << val_f

    td_g_first = giri_tr_first.css('td:nth-child(4)').first
    td_g_last = giri_tr_last.css('td:nth-child(4)').first
    (val_g = calculate(td_g_first.content, td_g_last.content)) unless (td_g_first.nil? or td_g_last.nil?)
    vals << val_g

    vals
  end

  def parse_pool_hij doc
    vals = []

  # doc = Nokogiri::HTML(open(url))
    giri_table = doc.css('table')[1]
    giri_tr_first = giri_table.css('tr:nth-child(3)')
    giri_tr_last = giri_table.css('tr:last-child')

    td_e_first = giri_tr_first.css('td:nth-child(3)').first
    td_e_last = giri_tr_last.css('td:nth-child(3)').first
    val_e = calculate(td_e_first.content, td_e_last.content) unless (td_e_first.nil? or td_e_last.nil?)
    vals << val_e

    td_f_first = giri_tr_first.css('td:nth-child(4)').first
    td_f_last = giri_tr_last.css('td:nth-child(4)').first
    val_f = calculate(td_f_first.content, td_f_last.content) unless (td_f_first.nil? or td_f_last.nil?)
    vals << val_f

    td_g_first = giri_tr_first.css('td:nth-child(5)').first
    td_g_last = giri_tr_last.css('td:nth-child(5)').first
    val_g = calculate(td_g_first.content, td_g_last.content) unless (td_g_first.nil? or td_g_last.nil?)
    vals << val_g

    vals
  end

  def parse_pool url
    doc = Nokogiri::HTML(open(url))
    vals1 = parse_pool_efg doc
    vals2 = parse_pool_hij doc
    vals1 + vals2
  end
end
