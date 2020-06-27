require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    vowels = %w[a e i o u]
    consonants = %w[b c d f g h j k l m n p q r s t v w x y z]
    @letters = (vowels.sample(3) + consonants.sample(6)).shuffle
  end

  def score
    session[:score] = 0

    response = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{params[:word]}").read)
    array_diff = array_difference(params[:word].split(''), params[:letters].split(' '))

    if array_diff.length != 0
      @message = "Sorry, but '#{params[:word]}' can't be built out of '#{params[:letters].upcase}'"
    elsif !response['found']
      @message = "Sorry, but '#{params[:word]}' does not seem to be a valid English word..."
    else
      @message = "Congratulations! '#{params[:word]}' is a valid English word!"
      display_words
      calculate_score(params[:word])
    end
  end

  def array_difference(x, y)
    ret = x.dup
    y.each do |element|
      if index = ret.index(element)
        ret.delete_at(index)
      end
    end
    ret
  end

  def calculate_score(word)
    session[:longest_word] = '' if session[:longest_word] == nil
    session[:total_score] = 0 if session[:total_score] == nil

    session[:score] = word.length ** 2
    session[:total_score] += session[:score]
    if word.length >= session[:longest_word].length
      session[:longest_word] = word
    end
  end

  def display_words
    session[:words_array] = [] if session[:words_array] == nil
    session[:words_array] << params[:word]
    session[:words_array] = session[:words_array].uniq.sort_by(&:length)[0..9].reverse
  end

  def reset
    session[:total_score] = 0
    session[:longest_word] = ''
    session[:words_array] = []
  end
end
