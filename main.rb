require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  if session[:username]
    redirect '/welcome'
  else
    erb :username
  end
end

get '/username' do
  erb :username
end

post '/username' do
  session[:username] = params[:username]
  redirect '/welcome'
end

get '/welcome' do
  erb :welcome
end

get '/game' do
  "game"
end