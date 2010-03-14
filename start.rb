#!/opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require 'sinatra'
require 'yaml'
require 'haml'
require "word2id"
require "doc2id"
require 'inverted_index'
require 'pp'

config = YAML.load_file("config.yaml")
pp config

get '/search/:name' do
  term = params[:name].force_encoding('UTF-8')
  word2id = Word2ID.new({"host" => config["word2id"]["host"], 
                          "port" => config["word2id"]["port"]})

  doc2id = Doc2ID.new({"host" => config["doc2id"]["host"], 
                        "port" => config["doc2id"]["port"]})
  inverted_index = InvertedIndex.new({"word2id" => word2id,
                                       "doc2id" => doc2id,
                                       "host" => config["word2docs"]["host"], 
                                       "port" => config["word2docs"]["port"]})
  
  @result = inverted_index.getDocs(term).map{|doc_id|
    doc2id[doc_id]
  }

  inverted_index.close
  word2id.close
  doc2id.close

  haml :search
end