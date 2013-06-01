#!/usr/bin/env ruby

## This analyzes a form using filter and distribution approach
# Basic usage:
# {"input": {"col1":["value1", "value2"], "col2":["valueA"]}, "output":["col3", "col4"]}
# which means
# for rows with col1 having value1 AND value2, AND col2 having valueA, get the distribution of all values in col3, col4
# output will something like {"col3":[{"value":"valueX", "count":1, "pct":10}, {"value":"valueY", "count":9, "pct":90}], "col4":[...]}


# Assumptions on table
# 1. it's tsv
# 2. first row is for column names (e.g. "col1", "col2")
# 3. each value cell can be a single value string, or comma separated multiple values

class TableAnalyzer

  def self.analyze(table, command)
    # table is a tsv string, command is the dict with input and output

    # init output arrays 
    result = Hash.new
    command["output"].each {|col| result[col] = Array.new}
    # puts result

    data_row_count = table.split("\n").count - 1
    if data_row_count<1
      return result
    end

    input_keys_to_watch = command["input"].keys 
    col_num_to_filter_map = Hash.new
    col_num_to_result_map = Hash.new

    table.split("\n").each_with_index do |line, idx|
      if idx==0
        line.split("\t").each_with_index do |col, idx2|
          if input_keys_to_watch.count(col)
            col_num_to_filter_map[idx2] = command["input"][col] # array
          end
          if command["output"].count(col)
            col_num_to_result_map[idx2] = result[col] # array
          end
        end
        # puts col_num_to_filter_map
        puts col_num_to_result_map
      else
        line.split("\t").each_with_index do |col, idx2|
        end 
      end
    end
  end
end

