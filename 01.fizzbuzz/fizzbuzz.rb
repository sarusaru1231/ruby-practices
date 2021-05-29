#!/usr/bin/env ruby

def fizz_buzz
  1.upto(20){|i|
    if i % 3 == 0 && i % 5 == 0 then
      puts "FizzBuzz"
    elsif i % 3 == 0 then
      puts "Fizz"
    elsif i % 5 == 0 then
      puts "Buzz"
    else
      puts i
    end
  }
end

fizz_buzz
