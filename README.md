# rubiphom

The Ruby solution to *phom*

---

*rubiphom* is a Ruby wrapper for the *phom* R package to compute persistent homology. Although *rubiphom* harnesses all the power of *phom* and its native language R, you do not actually need to know R. Just pure, shiny Ruby.

For further questions on the *phom* package, what it does, and how to use it, please refer to the [offical *phom* documentation](http://cran.r-project.org/web/packages/phom/phom.pdf). All R examples you see here are taken from that documentation.

## Release
Version 1.0.0 (C) 2013

## Usage
All plots are written to PDFs in the same directory from which your script is run. Each PDF contains one plot and is named according to your plot title (plus a random, unique ID). If no plot title is provided, a random, unique file name will be chosen.

### Example 1

Use *rubiphom* in your Ruby script as follows:

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

    rp.plotPersistenceDiagram(intervals, max_dim, max_f,
        :title => "Random Points in Cube with l_1 Norm")

The equivalent in R would be:
 
    library(phom)
    
    x <- runif(100)
    y <- runif(100)
    points <- t(as.matrix(rbind(x, y)))
    
    max_dim <- 2
    max_f <- 0.2
    
    intervals <- pHom(points, max_dim, max_f, metric="manhattan")
    
    plotPersistenceDiagram(intervals, max_dim, max_f,
        title="Random Points in Cube with l_1 Norm")
     
### Example 2

Another example of how to use *rubiphom* in your Ruby script:
    
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

    rp.plotPersistenceDiagram(intervals, max_dim, max_f,
        :title => "Random Points on S^1 with Euclidean Norm")

The equivalent in R would be:

    library(phom)
    
    t <- 2 * pi * runif(100)
    x <- cos(t); y <- sin(t)
    X <- t(as.matrix(rbind(x, y)))
    
    max_dim <- 1
    max_f <- 0.6
    
    intervals <- pHom(X, max_dim, max_f)
    
    plotPersistenceDiagram(intervals, max_dim, max_f,
        title="Random Points on S^1 with Euclidean Norm")

## Requirements
- Ruby 1.9+
- R and Rscript
- *phom* for R
- *Rcpp* for R (*phom* dependency)

## Installation

1. Install Ruby 1.9+. Official documentation is [here](https://www.ruby-lang.org/en/downloads/).
1. Install R. Official documentation is [here](http://cran.r-project.org/doc/manuals/R-admin.html).
1. Install the *Rcpp* and *phom* packages for R. You can run the following R snippet:

       install.packages("Rcpp", "phom")
       
1. Download *rubiphom.rb* from here, and put it in the same directory as your Ruby script.

## Author

Sean Ephraim | sean-ephraim@uiowa.edu