#!/usr/bin/env ruby

require 'sinatra'
require 'slim'
require 'json'
require "#{File.expand_path File.dirname(__FILE__)}/analyze.rb"

get '/hi' do
  "hi\n"
end


get '/' do
  slim :index
end

post '/' do
  table = params["tsv"]
  command = {}
  command["output"] = params["output"].split(",").map{|x| x.strip}
  command["input"] = {}
  (0..4).each do |idx|
    k = params["input_k_#{idx}"].strip
    v_str = params["input_v_#{idx}"].strip
    if k.length>0 and v_str.length>0
      command["input"][k] = v_str.split(",").map{|x| x.strip}
    end
  end
  @result = TableAnalyzer.analyze(table, command)
  slim :result
end

post '/analyze' do
  table = params[:tsv]
  command = params[:cmd]
  unless table and command
    return {"error" =>  "needed params: tsv & cmd"}.to_json
  end
  result = TableAnalyzer.analyze(table, JSON.parse(command))
  return result.to_json
end


__END__
@@layout

doctype html
html
  head
    script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"
    css:
      textarea {width:500px; height:150px;}
      label {width:300px; display:inline-block}
      input[type="text"] {width:200px}
  body
    == yield

@@index

form method="post"
  strong
    The data table (tsv format)
  br
  textarea name="tsv"
  br
  | note: the first row must be the title row (i.e. names of each column)
  br
  br
  label  Output columns (separate with comma)
  input type="text" name="output"
  br
  br
  hr
  p
    strong Filters (optional)
  - (0..4).each do |idx| 
    label Filter column
    input type="text" name="input_k_#{idx}"
    br
    label Value(s) (separate with comma)
    input type="text" name="input_v_#{idx}"
    br
    br
  input type="submit" value="Submit"

  javascript:
      $("textarea").keydown(function(e) {
        var $this, end, start;
        if (e.keyCode === 9) {
          start = this.selectionStart;
          end = this.selectionEnd;
          $this = $(this);
          $this.val($this.val().substring(0, start) + "\t" + $this.val().substring(end));
          this.selectionStart = this.selectionEnd = start + 1;
          return false;
        }
      });


@@result
p Result

- @result.each do |k,v|
  p #{k}
  - v.each do |item|
    ul
      li  #{item["value"]} : #{item["count"]} (#{item["pct"]} %)
  hr
