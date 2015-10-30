# Some documentation :)
require 'rubygems'
require 'sinatra'
#require "sinatra/reloader" if development?
require 'erb'
require 'dm-timestamps'
require 'mongo'
require 'uri'

set :erubis, :escape_html => true

class Database
	def self.initialize
		uri   = ENV["MONGOLAB_URI"] || "mongodb://localhost:27017/ihatejsf"
		mongo = Mongo::Connection.from_uri(uri)
		uri   = URI.parse(uri)
		@@db   = mongo.db(uri.path.gsub(/^\//, ''))
	end

	def self.db
		@@db
	end

	def self.[](collection)
		@@db.collection(collection)
	end

	def self.next_id(collection)
	    self["counters"].find_and_modify({ :query => { :_id => collection }, :update => { "$inc" => { :sequence => 1 } } })
	end
end

Database.initialize

class Logger
	def self.initialize
		if !Database.db.collection_names.include?("log")
			@@collection = Database.db.create_collection("log", :capped => true, :size => 100000, :max => 1000)
		else
			@@collection = Database["log"]
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

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  Logger.log("GET /")
  @posts = Database["posts"].find.sort([[ 'created', 'descending' ]])
  erb :index
end

post '/complain' do
  Logger.log("POST /complain")
  Database["posts"].insert({
    :_id => Database.next_id("posts"),
    :author => params[:nick],
    :text => params[:text],
    :created => Time.new
  })
  "OK"
end

get '/list' do
  Logger.log("GET /list")
  @posts = Database["posts"].find.sort([[ 'created', 'descending' ]])
  erb :posts, :layout => false
end

get '/post/:id' do
  Logger.log("GET /post/" + params[:id])
  post = Database["posts"].find_one({ :_id => Integer(params[:id]) })
  if post
    erb :single_post, :locals => { :post => post }
  else
    Logger.log("post with id " + params[:id] + " not found - returning index")
    @posts = Database["posts"].find.sort([[ 'created', 'descending' ]])
    erb :index
  end
end
