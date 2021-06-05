#!/usr/bin/env ruby

require 'optparse'
require 'date'

def main
  year, month = input_option
  display_calendar(year, month)
end

def input_option
  opt = OptionParser.new
  params = {}

  opt.on('-y [YEAR]') {|v| v }
  opt.on('-m [MONTH]') {|v| v }
  opt.parse!(ARGV, into: params)

  year = params[:y].nil? ? Date.today.year : params[:y].to_i
  month = params[:m].nil? ? Date.today.month : params[:m].to_i

  return year, month
end

def display_calendar(year, month)
  today = Date.today

  month_firstday = 1
  month_lastday = Date.new(year, month, -1).day
  month_start_wday = Date.new(year, month, 1).wday

  puts "      #{month}月 #{year}     "
  puts "日 月 火 水 木 金 土"
  1.upto(month_start_wday) {print "   "}

  month_firstday.upto(month_lastday) {|i|
    if month == today.month && year == today.year && i == today.day
      print "\e[30m\e[47m" + sprintf("%2d", i) + "\e[0m"
    else
      print sprintf("%2d", i)
    end

    print(" ")

    if Date.new(year, month, i).saturday?
      print("\n")
    end
  }

  print("\n")
end

main
