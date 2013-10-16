require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  erb :username
end

post '/username' do
  redirect '/welcome'
end

get '/welcome' do
  erb :welcome
end
