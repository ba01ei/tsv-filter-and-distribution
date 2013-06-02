
require "#{File.expand_path File.dirname(__FILE__)}/analyze.rb"
require "test/unit"

class TestTableAnalyzer < Test::Unit::TestCase

  def test_analyze
    table = "A\tB\tC\n1\t2\t3\n1\t2\t5\n1\t4\t3\n1\t4\t7,5\n2\t5\t9"
    out = TableAnalyzer.analyze(table, {"input"=>{"A"=>["1"]}, "output"=>["C"]})
  end

end