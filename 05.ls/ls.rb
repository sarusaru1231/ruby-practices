#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'readline'

class FileInformation
  attr_accessor :directory_path, :file_name, :file_type, :file_permission, :file_hardlink_number, :file_owner,
                :file_group, :file_size, :file_timestamp, :file_blocks

  def initialize(directory_path, file_name)
    @directory_path = directory_path
    @file_name = file_name
    file_status = File.lstat("#{directory_path}#{file_name}")
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
  if File.directory?(path)
    directory_path = path.match?(%r{.*/$}) ? path : "#{path}/"
    file_name_list = Dir.entries(directory_path).sort
  else
    path = path.match(%r{(.*/)(.*)})
    directory_path = path[1]
    file_name_list = [path[2]]
  end
  file_name_list = output_exclude_starting_dot_file(file_name_list) if options['a'] == false
  file_name_list = output_reverse(file_name_list) if options['r'] == true
  options['l'] == true ? output_long(file_name_list, directory_path) : output_standard(file_name_list)
end

def input_option
  options = ARGV.getopts('lar')
  path = ARGV[0].nil? ? Dir.getwd : ARGV[0]
  [options, path]
end

def output_standard(file_name_list)
  tab_width = 8
  terminal_width = `tput cols`.to_i
  file_name_length = file_name_list.max { |x, y| x.encode('EUC-JP').bytesize <=> y.encode('EUC-JP').bytesize }.encode('EUC-JP').bytesize
  column_width =  (file_name_length + tab_width) & ~(tab_width - 1)
  column_number = terminal_width / column_width
  row_number = file_name_list.length.divmod(column_number).sum
  if terminal_width < 2 * column_width
    print_one_column_file_name(file_name_list)
  else
    print_multi_columns_file_name(file_name_list, row_number, column_number, column_width, tab_width)
  end
end

def output_reverse(file_name_list)
  file_name_list.reverse
end

def output_exclude_starting_dot_file(file_name_list)
  file_name_list.reject { |s| s =~ /^\..*/ }
end

def output_long(file_name_list, directory_path)
  file_information_list = []
  file_name_list.map do |file|
    file_information = FileInformation.new(directory_path, File.directory?("#{directory_path}#{file}") ? "#{file}/" : file)
    file_information_list << file_information
  end
  print_long_one_column_file_name(file_information_list)
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
    '10' => '-',
    '12' => 'l',
    '40' => 'd'
  }
  translate_number_to_char_of_types.key?(type_s) ? translate_number_to_char_of_types[type_s] : '-'
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

def print_file_name(file_name)
  print file_name
  file_name.encode('EUC-JP').bytesize
end

def print_one_column_file_name(file_name_list)
  file_name_list.map { |file| puts file }
end

def print_multi_columns_file_name(file_name_list, row_number, column_number, column_width, tab_width)
  row = 0
  while row < row_number
    index = row
    i = 0
    while i < column_number
      break if index >= file_name_list.length

      char_count = print_file_name(file_name_list[index])
      index += row_number
      while char_count <= column_width && i < column_number - 1
        print "\t"
        char_count += tab_width
      end
      i += 1
    end
    puts
    row += 1
  end
end

def print_long_one_column_file_name(file_information_list)
  file_hardlink_number_width, file_owner_width, file_group_width, file_size_width = max_item_width(file_information_list)
  total_file_block = file_information_list.sum(&:file_blocks)

  puts "total: #{total_file_block}"
  file_information_list.map do |file_information|
    print format('%10s ', file_information.file_type + file_information.file_permission)
    print format("%#{file_hardlink_number_width}d ", file_information.file_hardlink_number)
    print format("%#{file_owner_width}s  ", file_information.file_owner)
    print format("%#{file_group_width}s  ", file_information.file_group)
    print format("%#{file_size_width}s ", file_information.file_size)
    print file_information.file_timestamp.strftime('%_2m %_2d %H:%M ')
    puts file_information.file_name
  end
end

main
