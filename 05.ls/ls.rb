#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'readline'

class FileInformation
  attr_reader :directory_path, :filename, :file_type, :file_permission, :file_hardlink_number, :file_owner,
              :file_group, :file_size, :file_timestamp, :file_blocks

  def initialize(directory_path, filename)
    @directory_path = directory_path
    @filename = filename
    file_status = File.lstat("#{directory_path}#{filename}")
    @file_permission = load_file_permission(format('0%o', file_status.mode))
    @file_type = load_file_type(format('0%o', file_status.mode))
    @file_hardlink_number = file_status.nlink
    @file_owner = Etc.getpwuid(file_status.uid).name
    @file_group = Etc.getgrgid(file_status.gid).name
    @file_size = file_status.size
    @file_timestamp = file_status.mtime
    @file_blocks = file_status.blocks
  end
end

def main
  options, path = input_option
  directory_path, filename_list = split_directory_file_path(path)
  filename_list = output_exclude_starting_dot_file(filename_list) if !options['a'] && File.directory?(path)
  filename_list = output_reverse(filename_list) if options['r']
  options['l'] ? output_long(filename_list, directory_path) : output_standard(filename_list)
end

def split_directory_file_path(path)
  if File.directory?(path)
    directory_path = File.join(path, '/')
    filename_list = Dir.entries(directory_path).sort
  else
    directory_path = nil
    filename_list = [path]
  end
  [directory_path, filename_list]
end

def input_option
  options = ARGV.getopts('lar')
  path = ARGV[0].nil? ? Dir.getwd : ARGV[0]
  [options, path]
end

def output_standard(filename_list)
  tab_width = 8
  terminal_width = `tput cols`.to_i
  filename_length = filename_list.max_by { |v| v.encode('UTF-8').bytesize }.encode('UTF-8').bytesize
  column_width =  (filename_length + tab_width) & ~(tab_width - 1)
  column_number = terminal_width / column_width
  row_number = (filename_list.length / column_number.to_f).ceil
  if terminal_width < column_width * 2
    print_one_column_filename(filename_list)
  else
    print_multi_columns_filename(filename_list, row_number, column_number, column_width, tab_width)
  end
end

def output_reverse(filename_list)
  filename_list.reverse
end

def output_exclude_starting_dot_file(filename_list)
  filename_list.reject { |s| s =~ /^\..*/ }
end

def output_long(filename_list, directory_path)
  file_information_list = []
  filename_list.each do |file|
    file_information = FileInformation.new(directory_path, file)
    file_information_list << file_information
  end
  print_long_one_column_filename(file_information_list)
end

def load_file_permission(file_status_mode)
  permission_s = file_status_mode[-3..-1]
  translate_number_to_char_of_permissions = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }
  permission_result = ''
  permission_s.each_char do |c|
    permission_result += translate_number_to_char_of_permissions[c]
  end
  permission_result
end

def load_file_type(file_status_mode)
  type_s = file_status_mode[1..2]
  translate_number_to_char_of_types = {
    '12' => 'l',
    '40' => 'd'
  }
  translate_number_to_char_of_types.default = '-'
  translate_number_to_char_of_types[type_s]
end

def max_item_width(file_information_list)
  max_file_hardlink_number_width = 2
  max_file_owner_width = 0
  max_file_group_width = 0
  max_file_size_width = 0
  file_information_list.map do |file_information|
    if file_information.file_hardlink_number.to_s.length > max_file_hardlink_number_width
      max_file_hardlink_number_width = file_information.file_hardlink_number.to_s.length
    end
    max_file_owner_width = file_information.file_owner.length if file_information.file_owner.length > max_file_owner_width
    max_file_group_width = file_information.file_group.length if file_information.file_group.length > max_file_group_width
    max_file_size_width = file_information.file_size.to_s.length if file_information.file_size.to_s.length > max_file_size_width
  end
  [max_file_hardlink_number_width, max_file_owner_width, max_file_group_width, max_file_size_width]
end

def print_filename(filename)
  print filename
  filename.encode('UTF-8').bytesize
end

def print_one_column_filename(filename_list)
  filename_list.map { |file| puts file }
end

def print_multi_columns_filename(filename_list, row_number, column_number, column_width, tab_width)
  (0...row_number).each do |row|
    index = row
    (0...column_number).each do |i|
      break if index >= filename_list.length

      char_count = print_filename(filename_list[index])
      index += row_number
      while char_count <= column_width && i < column_number - 1
        print "\t"
        char_count += tab_width
      end
    end
    puts
  end
end

def print_long_one_column_filename(file_information_list)
  file_hardlink_number_width, file_owner_width, file_group_width, file_size_width = max_item_width(file_information_list)
  total_file_block = file_information_list.sum(&:file_blocks)
  puts "total #{total_file_block}"
  file_information_list.map do |file_information|
    print format('%10s ', file_information.file_type + file_information.file_permission)
    print format("%#{file_hardlink_number_width}d ", file_information.file_hardlink_number)
    print format("%#{file_owner_width}s  ", file_information.file_owner)
    print format("%#{file_group_width}s  ", file_information.file_group)
    print format("%#{file_size_width}s ", file_information.file_size)
    print file_information.file_timestamp.strftime('%_2m %_2d %H:%M ')
    puts file_information.filename
  end
end

main
