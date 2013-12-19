# EXAMPLE 2
require './rubiphom.rb'

rp = Rubiphom.new
t = Array.new
x = Array.new
y = Array.new

100.times {t << 2*Math::PI*rand}
t.each {|elem|x << Math.cos(elem)}
t.each {|elem|y << Math.sin(elem)}
data = [x,y].transpose

max_dim = 1
max_f = 0.6

intervals = rp.pHom(data, max_dim, max_f)

rp.plotPersistenceDiagram(intervals, max_dim, max_f, :title => "Random Points on S^1 with Euclidean Norm")
