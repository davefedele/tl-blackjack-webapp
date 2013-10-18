require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do

  def calculate_total(cards) # cards is [['D', '4'], ['H', 'A'] ...]
    arr = cards.map {|e| e[1]}

    total = 0

    arr.each do |value|
      if value == 'A'
        total += 11
      else 
        total += value.to_i == 0 ? 10 : value.to_i
      end
    end

    #correct for Aces
    arr.select {|v| v == 'A'}.count do
      break if total <= 21
      total -=10
    end

    total
  end

  def card_image(card) #['H', '10']
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    value = card[1]
    
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'>" 
  
   end

end


before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:username]
    redirect '/game'
  else
    erb :username
  end
end

get '/username' do
  erb :username
end

post '/username' do
  if params[:username].empty?
    @error = "A name is required."
    halt erb(:username)
  end

  session[:username] = params[:username]
  redirect '/game'
end

get '/game' do
  # deck 
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle! # cards is [['D', '4'], ['H', 'A'] ...]

  session[:dealer_cards] = []
  session[:player_cards] = []

  2.times do
    session[:dealer_cards] << session[:deck].pop 
    session[:player_cards] << session[:deck].pop 
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop 
  
  player_total = calculate_total(session[:player_cards])

  if player_total == 21
    @success = "Blackjack! Congratulations #{session[:username]} hit blackjack!" 
    @show_hit_or_stay_buttons = false 
  elsif player_total > 21
    @error = "Sorry, #{session[:username]} busted!"
    @show_hit_or_stay_buttons = false 
  end
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:username]} has chosen to stay."
  @show_hit_or_stay_buttons = false
  erb :game
end