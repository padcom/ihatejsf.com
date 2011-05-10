require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'

DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/development.db")

class Post
  include DataMapper::Resource

  property :id, Serial
  property :nick, Text
  property :text, Text
  property :created_at, DateTime
end

DataMapper.auto_upgrade!

get '/' do
  @posts = Post.all(:order => [ :created_at.desc ])
  erb :index
end

post '/complain' do
  Post.create(:text => params[:text], :nick => params[:nick]) 
  "OK"
end

get '/list' do
  @posts = Post.all(:order => [ :created_at.desc ])
  erb :posts, :layout => false
end

get '/post/:id' do
  post = Post.get(params[:id])
  if post
    erb :single_post, :locals => { :post => post }
  else
    erb :index
  end
end
