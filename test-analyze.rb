
require "#{File.expand_path File.dirname(__FILE__)}/analyze.rb"
require "test/unit"

class TestTableAnalyzer < Test::Unit::TestCase

  def test_analyze
    table = "A\tB\tC\n1\t2\t3"
    out = TableAnalyzer.analyze(table, {"input"=>{"A"=>["1"]}, "output"=>["C"]})
  end

end