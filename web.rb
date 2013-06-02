#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require "#{File.expand_path File.dirname(__FILE__)}/analyze.rb"

get '/hi' do
  "hi\n"
end

post '/analyze' do
  table = params[:tsv]
  command = params[:cmd]
  unless table and command
    return {"error" =>  "needed params: tsv & cmd"}.to_json
  end
  puts "table:"
  puts table
  puts "command:"
  puts command
  result = TableAnalyzer.analyze(table, JSON.parse(command))
  puts "result:"
  puts result
  return result.to_json
end

