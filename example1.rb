# EXAMPLE 1
require './rubiphom.rb'

rp = Rubiphom.new
x = Array.new
y = Array.new

# Create random distributions, x and y
[x,y].each {|n| 100.times {n << rand}}
points = [x,y].transpose

max_dim = 2
max_f = 0.2

intervals = rp.pHom(points, max_dim, max_f, :metric => "manhattan")

rp.plotPersistenceDiagram(intervals, max_dim, max_f, :title => "Random Points in Cube with l_1 Norm")
