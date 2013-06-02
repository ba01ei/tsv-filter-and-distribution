tsv filter and distribution
===========================

It is a tool to analyze tsv (tab separated value) data, through command, api, or web interface.

Usage
=====

Requirement on the table:
The columns need to be tab-separated.
The rows need to be ended with \n.
It needs to have a title row.
If a cell has multiple values, they need to be separated by comma.

Example:
Column1	Column2	Column3
A	1	X,3,Y
B	2	Y,4
A	5	Z

1. Command line mode
./analyze filename [-i column1=value1 [-i column2=value2]] -o column3,column4,column5

2. API mode
start the web server (Sinatra based):
bundle install
./web.rb

Post at /analyze, with params:
tsv : the tsv string
cmd : the command in json. example: {"input": {"col1":["value1", "value2"], "col2":["valueA"]}, "output":["col3", "col4"]}

3. Web mode
start the web server, then visit the web

Note:
If multiple column filters are used, or if one filter has multiple values, they are all in AND relation, instead of OR.

e.g. if we have table
Row  Column1	Column2
1    a,b,c	X
2    a,c	Y

With filter {"Column1":["a", "b"]}, row 1 will pass but row 2 will fail.


License
=======

Copyright (c) 2013 Bao Lei

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

