require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'mongo'

DataMapper.setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/development.db")

class Logger 
	def self.initialize
		uri = URI.parse(ENV["MONGOLAB_URI"] || "mongodb://localhost:27017/ihatejsf")
		puts uri
		puts uri.host
		puts uri.port
		puts uri.user
		puts uri.password
		puts uri.path
		db = Mongo::Connection.new(uri.host).db(uri.path[1..-1])
		if not uri.user.nil?
			db.authenticate(uri.user, uri.password)
		end
		if db.collection_names.include?("log")
			@@collection = db.collection("log")
		else
			@@collection = db.create_collection("log", :capped => true, :size => 100000, :max => 1000)
		end
	end

	def self.log(s)
		@@collection.save({
			:timestamp => Time.now.utc,
			:message   => s
		})
	end
end

Logger.initialize

class Post
  include DataMapper::Resource

  property :id, Serial
  property :nick, Text
  property :text, Text
  property :created_at, DateTime
end

DataMapper.auto_upgrade!

get '/' do
  Logger.log("GET /")
  @posts = Post.all(:order => [ :created_at.desc ])
  erb :index
end

post '/complain' do
  Logger.log("POST /complain")
  Post.create(:text => params[:text], :nick => params[:nick]) 
  "OK"
end

get '/list' do
  Logger.log("GET /list")
  @posts = Post.all(:order => [ :created_at.desc ])
  erb :posts, :layout => false
end

get '/post/:id' do
  Logger.log("GET /post/" + params[:id])
  post = Post.get(params[:id])
  if post
    erb :single_post, :locals => { :post => post }
  else
    erb :index
  end
end
