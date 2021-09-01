#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  option = ARGV.getopts('l')
  paths = ARGV
  if ARGV.empty?
    lines = $stdin.readlines
    if option['l']
      puts format('%8d', lines.length)
    else
      line_count, word_count, byte_count = count_line_word_byte(lines)
      puts format('%<line_count>8d%<word_count>8d%<byte_count>8d', line_count: line_count, word_count: word_count, byte_count: byte_count)
    end
  elsif option['l']
    print_line_count_from_files(paths)
  else
    print_counts_from_files(paths)
  end
end

def print_line_count_from_files(paths)
  total_line_count = 0
  paths.each do |path|
    f = File.open(path, 'r')
    line_count = f.readlines.length
    puts format('%<line_count>8d %<path>s', line_count: line_count, path: path)
    total_line_count += line_count
  end
  puts format('%8d total', total_line_count) if paths.length > 1
end

def print_counts_from_files(paths)
  total_line_count = total_word_count = total_byte_count = 0
  paths.each do |path|
    f = File.open(path, 'r')
    line_count, word_count, byte_count = count_line_word_byte(f.readlines)
    puts format('%<line_count>8d%<word_count>8d%<byte_count>8d %<path>s', line_count: line_count, word_count: word_count, byte_count: byte_count, path: path)
    total_line_count += line_count
    total_word_count += word_count
    total_byte_count += byte_count
  end
  return unless paths.length > 1

  puts format("%<line_count>8d%<word_count>8d%<byte_count>8d total\n", line_count: total_line_count,
                                                                       word_count: total_word_count, byte_count: total_byte_count)
end

def count_line_word_byte(lines)
  line_count = lines.length
  word_count = byte_count = 0
  lines.each do |line|
    byte_count += line.bytesize
    words = line.chomp.split("\s")
    word_count += words.length
  end
  [line_count, word_count, byte_count]
end

main
