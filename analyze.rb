#!/usr/bin/env ruby

## This analyzes a form using filter and distribution approach
# Basic usage:
# {"input": {"col1":["value1", "value2"], "col2":["valueA"]}, "multiplier":"colCount", "output":["col3", "col4"]}
# which means
# for rows with col1 having value1 AND value2, AND col2 having valueA, get the distribution of all values in col3, col4
# output will something like {"col3":[{"value":"valueX", "count":1, "pct":10}, {"value":"valueY", "count":9, "pct":90}], "col4":[...]}


# Assumptions on table
# 1. it's tsv
# 2. first row is for column names (e.g. "col1", "col2")
# 3. each value cell can be a single value string, or comma separated multiple values

require 'yaml'

class TableAnalyzer

  def self.analyze(table, command)
    # table is a tsv string, command is the dict with input and output

    # init output arrays 
    result = Hash.new
    command["output"].each {|col| result[col] = Array.new}
    # puts result

    data_row_count = table.split("\n").count - 1
    rows_used = 0

    command["input"]={} unless command["input"]
    input_keys_to_watch = command["input"].keys 
    col_num_to_filter_map = Hash.new
    col_num_to_result_map = Hash.new
    col_val_result_dict = Hash.new # like {"3(col index)":{"valueX": the_array_in_results}}

    filter_cols = []
    result_cols = []
    multiplier_col = nil

    table.strip! # handle the case when there's an empty line at the beginning
    table.split("\n").each_with_index do |line, idx|
      ok_to_use_row = true
      if idx==0
        line.split("\t").each_with_index do |col, idx2|
          col.strip!
          if input_keys_to_watch.count(col)>0
            # puts "input_keys_to_watch=#{input_keys_to_watch} which has #{col} for col #{idx2}"
            col_num_to_filter_map[idx2] = command["input"][col] # array
            filter_cols << idx2
          end
          if command["output"].count(col)>0
            col_num_to_result_map[idx2] = result[col] # array
            col_val_result_dict[idx2] = {}
            result_cols << idx2
          end
          if command["multiplier"] and command["multiplier"].count(col) > 0
            multiplier_col = idx2
          end
        end
        # puts col_num_to_filter_map
        # puts "result cols: #{result_cols}, map: #{col_num_to_result_map}"
        # puts "filter cols: #{filter_cols}"
      else
        columns = line.split("\t")
        filter_cols.each do |idx2|
          values_str = columns[idx2]
          unless values_str
            ok_to_use_row = false
            break
          end
          values = columns[idx2].split(",").map{|v| v.strip}
          filters = col_num_to_filter_map[idx2]

          # puts "values - filters = #{values} - #{filters}"
          if (values - filters).count != (values.count - filters.count)
            # filters has something values doesn't have
            # puts "no match at row #{idx} for col #{idx2}"
            ok_to_use_row = false
            break # quit col loop
          end
        end

        unless ok_to_use_row # quit row loop
          # puts "row #{idx} doesn't qualify"
          next
        end
        rows_used += multiplier_col ? columns[multiplier_col].to_f :  1.0

        result_cols.each do |idx2|
          # puts "columns: #{columns}, idx:#{idx2}"
          values_str = columns[idx2]
          break unless values_str
          break if values_str.length < 1
          values = columns[idx2].split(",").map{|v| v.strip}
          result_array = col_num_to_result_map[idx2]
          found = false
          values.each do |value|
            if col_val_result_dict[idx2][value]
              col_val_result_dict[idx2][value]["count"] += multiplier_col ? columns[multiplier_col].to_f :  1.0
            else
              col_val_result_dict[idx2][value] = {"value"=>value, "count"=> multiplier_col ? columns[multiplier_col].to_f :  1.0}
              result_array << col_val_result_dict[idx2][value]
            end
          end # of value loop
          
        end # of col loop
      end # of row
      # puts "result is #{result} after row #{idx}"
    end # of all rows

    # add percentage
    command["output"].each do |col|
      result[col].each do |item|
        # puts "count: #{item["count"]}, rows:#{rows_used}, result:#{item["count"].to_f/rows_used.to_f}"
        item["pct"] = (item["count"].to_f * 100.0 / rows_used.to_f).round.to_i
      end
    end
    
    # puts "result is #{result}"
    return result
  end
end

if __FILE__ == $0
  if ARGV.count < 3
    puts "Usage:\nanalyze filename [-i column1=value1 [-i column2=value2]] -o column3,column4,column5\n\n"
    exit 1
  end
  filename = ARGV[0]
  args = ARGV[1..-1].join(' ')
  inputs = args.scan(/-i ([^-]*)/).map{|a| a[0]}
  outputs = args.scan(/-o ([^-]*)/).map{|a| a[0]}
  # puts inputs.inspect
  # puts outputs.inspect
  if outputs.count<1
    puts "Need at least one output column\n\n"
    exit 1
  end
  cmd = {"output"=>[], "input"=>{}}

  # handle output
  outputs.each do |output|
    cmd["output"] +=  output.split(",").map{|c| c.strip}
  end

  # handle input
  inputs.each do |input|
    array = input.split("=")
    if array.count==2
      key = array[0].strip
      values = array[1].strip
      cmd["input"][key] = values.split(",").map{|v| v.strip}
    end
  end

  # puts cmd

  result = TableAnalyzer.analyze(File.read(filename), cmd)
  puts result.to_yaml
end