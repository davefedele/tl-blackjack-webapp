require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17
INITIAL_POT_AMOUNT = 500
BLACKJACK_PAYOUT_AMOUNT = 1.5

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
      break if total <= BLACKJACK_AMOUNT
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

  def winner!(msg)
    @show_hit_or_stay_buttons = false
    @play_again = true
    
    player_total = calculate_total(session[:player_cards])
  
    if player_total == BLACKJACK_AMOUNT
      session[:player_pot] = session[:player_pot] + (session[:player_bet] * BLACKJACK_PAYOUT_AMOUNT)
    else
      session[:player_pot] = session[:player_pot] + session[:player_bet]
    end
    @winner = "<strong> #{session[:username]} wins! </strong> #{msg}"
  end

  def loser!(msg)
    @show_hit_or_stay_buttons = false
    @play_again = true
    session[:player_pot] = session[:player_pot] - session[:player_bet]
    @loser = "<strong> #{session[:username]} loses! </strong> #{msg}"
  end 

  def tie(msg)
    @show_hit_or_stay_buttons = false
    @play_again = true 
    @winner =  "<strong> It's a tie! </strong> #{msg}"
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
  session[:player_pot] = INITIAL_POT_AMOUNT
  erb :username
end

post '/username' do
  if params[:username].empty?
    @error = "A name is required."
    halt erb(:username)
  end

  session[:username] = params[:username]
  redirect '/bet'
end

get '/bet' do
  if session[:player_pot] == 0
    halt erb :game_over
  end
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:bet_amount].nil? || params[:bet_amount].to_i == 0 #all values from forms come in as string... to_i important
    @error = "You Must make a bet"
    halt erb :bet
  elsif params[:bet_amount].to_i > session[:player_pot]
    @error = "Bet amount can't exceed what you have ($#{session[:player_pot]})"
    halt erb  :bet
  else
    session[:player_bet] = params[:bet_amount].to_i   
    redirect '/game'
  end
end

get '/game' do
  session[:turn] = session[:username]

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

  if player_total == BLACKJACK_AMOUNT
    winner!("#{session[:username]} hit blackjack!")
  elsif player_total > BLACKJACK_AMOUNT
    loser!("#{session[:username]} busted at #{player_total}!")
  end
  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "#{session[:username]} has chosen to stay."
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT
    loser!("The dealer hit blackjack!")
  elsif dealer_total > BLACKJACK_AMOUNT
    winner!("The dealer busted at #{dealer_total}!")
  elsif dealer_total >= DEALER_MIN_HIT
    #dealer stays
    redirect '/game/compare'
  else
    @show_dealer_hit_button = true
  end

  erb :game, layout: false
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect 'game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total(session[:dealer_cards])
  player_total = calculate_total(session[:player_cards])
  
  if dealer_total > player_total
    loser!("#{session[:username]} stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
  elsif dealer_total < player_total
    winner!("#{session[:username]} stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
  else
    tie!("Both #{session[:username]} and the dealer stayed at {player_total}.")
  end

  erb :game, layout: false
end

get '/game_over' do
  erb :game_over
end