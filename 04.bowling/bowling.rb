#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  score = ARGV[0]
  scores = score.split(',')
  puts score_calculate(scores)
end

def score_calculate(scores)
  frames = convert_to_frames(scores)
  point = 0
  two_times_before = :normal
  one_time_before = :normal
  frames.each_with_index do |frame, frame_count|
    point, two_times_before = two_times_before_score_calculate(point, two_times_before, frame)
    point, two_times_before = one_time_before_score_calculate(point, one_time_before, frame)
    point, one_time_before = this_time_score_calculate(point, frame_count, frame)
  end
  point
end

def convert_to_frames(scores)
  shots = []
  scores.each do |s|
    if s == 'X'
      shots << 10
      shots << 0
    else
      shots << s.to_i
    end
  end
  frames = []
  shots.each_slice(2) do |s|
    s.length == 1 ? frames.last << s[0] : frames << s
  end
  frames
end

def one_time_before_score_calculate(point, one_time_before, frame)
  case one_time_before
  when :strike
    if frame[0] == 10
      two_times_before = :strike
      point += 10
    else
      point += frame[0] + frame[1]
    end
  when :spare
    point += frame[0]
  end
  [point, two_times_before]
end

def two_times_before_score_calculate(point, two_times_before, frame)
  if two_times_before == :strike
    point += frame[0]
    two_times_before = :normal
  end
  [point, two_times_before]
end

def this_time_score_calculate(point, frame_count, frame)
  one_time_before = :normal
  if frame_count >= 9 # frame10
    point += frame.sum
  elsif frame[0] == 10 # strike
    point += 10
    one_time_before = :strike
  elsif frame.sum == 10 # spare
    point += frame.sum
    one_time_before = :spare
  else
    point += frame.sum
  end
  [point, one_time_before]
end

main
