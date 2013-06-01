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
    rows_used = 0

    input_keys_to_watch = command["input"].keys 
    col_num_to_filter_map = Hash.new
    col_num_to_result_map = Hash.new
    col_val_result_dict = Hash.new # like {"3(col index)":{"valueX": the_array_in_results}}

    filter_cols = []
    result_cols = []

    table.split("\n").each_with_index do |line, idx|
      ok_to_use_row = true
      if idx==0
        line.split("\t").each_with_index do |col, idx2|
          if input_keys_to_watch.count(col)
            col_num_to_filter_map[idx2] = command["input"][col] # array
            filter_cols << idx2
          end
          if command["output"].count(col)
            col_num_to_result_map[idx2] = result[col] # array
            col_val_result_dict[idx2] = {}
            result_cols << idx2
          end
        end
        # puts col_num_to_filter_map
        # puts col_num_to_result_map
      else
        columns = line.split("\t")
        filter_cols.each do |idx2|
          values = columns[idx2].split(",").map{|v| v.strip}
          filters = col_num_to_result_map[idx2]

          unless values
            puts "row #{idx} col #{idx2} no values"
          end
          puts "row #{idx}, col #{idx2} no filters" unless filters
          if (values - filters).count != values.count - filters.count
            # filters has something values doesn't have
            ok_to_use_row = false
            break # quit col loop
          else
            rows_used += 1
          end
        end

        break unless ok_to_use_row # quit row loop

        result_cols.each do |idx2|
          values = columns[idx2].split(",").map{|v| v.strip}
          result_array = col_num_to_result_map[idx2]
          found = false
          values.each do |value|
            if col_val_result_dict[idx2][value]
              col_val_result_dict[idx2][value][count] += 1
            else
              col_value_result_dict[idx2][value] = 1
            end
          end # of value loop
          
        end # of col loop
      end # of row
    end # of all rows
    
    puts result
  end
end

