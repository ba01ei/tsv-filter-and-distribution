
require "#{File.expand_path File.dirname(__FILE__)}/analyze.rb"
require "test/unit"

class TestTableAnalyzer < Test::Unit::TestCase

  def test_analyze
    table = "A\tB\tC \n 1\t2\t3 \n 1\t2\t5 \n 1\t4\t3 \n 1\t4\t7,5 \n 2\t5\t9"
    puts table
    
    out = TableAnalyzer.analyze(table, {"input"=>{"A"=>["1"]}, "output"=>["C"]})
    puts out
    assert_equal out, {"C"=>[{"value"=>"3", "count"=>2, "pct"=>50}, {"value"=>"5", "count"=>2, "pct"=>50}, {"value"=>"7", "count"=>1, "pct"=>25}]}

    out = TableAnalyzer.analyze(table, {"input"=>{"C"=>["5","7"]}, "output"=>["A", "B"]})
    puts out
    assert_equal out, {"A"=>[{"value"=>"1", "count"=>1, "pct"=>100}], "B"=>[{"value"=>"4", "count"=>1, "pct"=>100}]}

    out = TableAnalyzer.analyze(table, {"input"=>{"A"=>["1"]}, "output"=>["C"], "multiplier"=>"B"})
    puts out
  end

end