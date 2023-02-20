require 'open-uri'
require 'json'
require 'time'

# Controls the wordgame
class WordgameController < ApplicationController
  def new
    alphabet = ('a'..'z').to_a

    @letters = []
    @time = Time.now

    9.times { @letters << alphabet.sample }
  end

  def result
    @letters = params[:letters].split
    @word = params[:word]
    @time = Time.now - params[:time].to_time

    words_array = @word.split('')
    # Check if all letters are in the array
    words_array.each do |letter|
      if @letters.include?(letter)
        # Delete the letter
        @letters.delete_at(@letters.index(letter))
      else
        @message = "Sorry but #{words_array.join.upcase} can't be build out of #{@letters.join(', ').upcase}"
        @score = 0
        return ''
      end
    end

    # Check if it's a valid word
    checked_word = check_word(@word)

    if checked_word['found']
      @score = calculate_score(checked_word['length'], @time)
      @message = "Congratulations! #{words_array.join.upcase} is a valid English word!"
      return ''
    end

    @message = "Sorry but #{words_array.join.upcase} doesn't seem to be a valid English word"
    @score = 0
  end

  private

  def check_word(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    user_serialized = URI.open(url).read
    JSON.parse(user_serialized)
  end

  def calculate_score(word_length, time)
    total = word_length - (time * 0.15)
    total.positive? ? total : 0
    (total * 100).round
  end
end
