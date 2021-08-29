#!/usr/bin/env ruby
# frozen_string_literal: true

def main
  score = ARGV[0]
  scores = score.split(',')
  puts score_calculate(scores)
end

def score_calculate(scores)
  frames = convert_to_frames(scores)
  total_point = 0
  frames.each_with_index do |this_frame, frame_number|
    total_point += this_frame.sum
    total_point += frames[frame_number + 2][0] if frame_number < 8 && (strike?(this_frame) && strike?(frames[frame_number + 1]))
    if frame_number < 9
      total_point += frames[frame_number + 1][0] + frames[frame_number + 1][1] if strike?(this_frame)
      total_point += frames[frame_number + 1][0] if spare?(this_frame)
    end
  end
  total_point
end

def strike?(frame)
  frame[0] == 10
end

def spare?(frame)
  frame[0] < 10 && frame.sum == 10
end

def convert_to_frames(scores)
  shots = []
  scores.each do |shot|
    if shot == 'X'
      shots << 10
      shots << 0 if shots.size < 18
    else
      shots << shot.to_i
    end
  end
  frames = []
  shots.each_slice(2) do |shot|
    shot.length == 1 ? frames.last << shot[0] : frames << shot
  end
  frames
end

main
