#!/usr/bin/env ruby

require 'optparse'
require 'date'

class YearMonth
  attr_reader :year, :month
  attr_writer :year, :month
end

def main
  year_month = YearMonth.new
  input_option(year_month)
  display_calendar(year_month)
end

def input_option(year_month)
  opt = OptionParser.new
  params = {}

  begin 
    opt.on('-y [YEAR]') {|v| v }
    opt.on('-m [MONTH]') {|v| v }
    opt.parse!(ARGV, into: params)

    if params[:y].nil?
      year_month.year = Date.today.year
    else
      year_month.year = params[:y].to_i
    end

    if year_month.year < 1 
      raise e
    end

    if params[:m].nil?
      year_month.month = Date.today.month
    else
      year_month.month = params[:m].to_i
    end

    if year_month.month < 1 || year_month.month > 12 
      raise e
    end
    
  rescue => e
    puts e.message + ": 入力された年月が不正です。使い方： ./cal.rb -y [YEAR] -m [MONTH]"

    exit
  end
end

def display_calendar(year_month)
  year = year_month.year
  month = year_month.month
  today = Date.today;

  begin 
    month_firstday = 1
    month_lastday = Date.new(year, month, -1).day
    month_start_wday = Date.new(year, month, 1).wday

    puts "      #{month}月 #{year}     "
    puts "日 月 火 水 木 金 土"
    1.upto(month_start_wday) {|i| print "   "}

    wday_cnt = month_start_wday
    
    if month == today.month && year == today.year
      month_firstday.upto(month_lastday) {|i|
        if i == today.day
          print "\e[30m\e[47m" + sprintf("%2d", i) + "\e[0m"
        else
          print sprintf("%2d", i)
        end

        print(" ")

        wday_cnt += 1
        
        if wday_cnt%7 == 0
          print("\n")
        end
      }
    else 
      month_firstday.upto(month_lastday) {|i|
        print sprintf("%2d", i)
        print(" ")

        wday_cnt += 1
        
        if wday_cnt%7 == 0
          print("\n")
        end
      }
    end
    
    print("\n")

  rescue => e
    puts e.message + ": 入力された年月が不正です。使い方： ./cal.rb -y [YEAR] -m MONTH"

    exit
  end
end

main
