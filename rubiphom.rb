require 'securerandom'

# A Ruby class for the phom R package.
#
# @author Sean Ephraim
class Rubiphom
  # Compute the persistent homology on a given dataset.
  #
  # @param [Array] x Data in the form of a matrix
  # @param [Integer] dimension Max dimension to compute persistent homology to
  # @param [Float] max_filtration_value Max filtration value to use in constructing the filtered complex
  # @param [Hash] opts Options for computing persistent homology
  # @option opts [String] :mode Type of filtration to use
  # @option opts [String] :metric Type of metric that will be used
  # @option opts [Integer] :p Value of the power to use in the Minkowski metric
  # @option opts [Integer] :landmark_set_size Number of points to include in the landmark set
  # @option opts [Integer] :maxmin_samples Number of samples to use when performing the maxmin selection
  def pHom(x, dimension, max_filtration_value, opts = {})
    # Find dimensions and convert matrix to R
    elements,nrow,ncol = getRmatrix(x)

    # Convert options from Ruby to R
    phom_opts = getRopts(opts, [:mode, :metric, :p, :landmark_set_size, :maxmin_samples])

    # Create R script and run it
    code = %Q{
      x <- matrix(c(#{elements}), nrow=#{nrow}, ncol=#{ncol})
      result <- pHom(x, #{dimension}, #{max_filtration_value}, #{phom_opts})
    }
    rmatrix = runRscript(code)

    intervals = getRubyMatrix(rmatrix)
    return intervals
  end

  # Plots a persistence diagram from a given set of intervals.
  #
  # @param [Array] intervals Matrix with 3 columns that specifies the persistence intervals
  # @param [Integer] max_dim Max dimension to plot
  # @param [Float] max_f Maximum filtration value to use in the persistence diagram
  # @param [Hash] opts Options for plotting diagram
  # @option opts [String] :title Title of the persistence diagram
  def plotPersistenceDiagram(intervals, max_dim, max_f, opts = {})
    filename = (opts[:title].nil?) ? "PersistenceDiagram_#{SecureRandom.hex(6)}.pdf" : "#{opts[:title]}_#{SecureRandom.hex(6)}.pdf"
    elements,nrow,ncol = getRmatrix(intervals)
    phom_opts = getRopts(opts, [:title])

    # Create R script and run it
    code = %Q{
      intervals <- matrix(c(#{elements}), nrow=#{nrow}, ncol=#{ncol})
      plotPersistenceDiagram(intervals, #{max_dim}, #{max_f}, #{phom_opts})
    }
    runRscript(code)

    # Move "Rplots.pdf" so it doesn't get overwritten
    File.rename("Rplots.pdf", sanitize_filename(filename))
  end

  # Plots a set of intervals as a set of line-segments.
  #
  # @param [Array] intervals Matrix with 3 columns that specifies the persistence intervals
  # @param [Integer] dimension The dimension to plot intervals for
  # @param [Float] max_f Maximum filtration value to use in the diagram
  # @param [Hash] opts Options for plotting diagram
  # @option opts [String] :title Title of the barcode diagram
  def plotBarcodeDiagram(intervals, dimension, max_f, opts = {})
    filename = (opts[:title].nil?) ? "BarcodeDiagram_#{SecureRandom.hex(6)}.pdf" : "#{opts[:title]}_#{SecureRandom.hex(6)}.pdf"
    elements,nrow,ncol = getRmatrix(intervals)
    phom_opts = getRopts(opts, [:title])

    # Create R script and run it
    code = %Q{
      intervals <- matrix(c(#{elements}), nrow=#{nrow}, ncol=#{ncol})
      plotBarcodeDiagram(intervals, #{dimension}, #{max_f}, #{phom_opts})
    }
    runRscript(code)

    # Move "Rplots.pdf" so it doesn't get overwritten
    File.rename("Rplots.pdf", sanitize_filename(filename))
  end
end

# Run code as an R script.
#
# @author Sean Ephraim
# @param [String] code R script code
# @return [String] R script result
def runRscript(code)
  code = %Q{
    library("Rcpp")
    library("phom")
    result <- NULL
    #{code}
    print(result)
  }
  # Write R script to file
  rscript = File.join("", "tmp", "rubiphom#{Process.pid}.R")
  File.open(rscript, 'w') {|f| f.write(code) }
  # Run R script
  result =  `Rscript #{rscript}`
  File.delete(rscript)
  return result
end

# Converts Ruby hashes to R options.
#
# @author Sean Ephraim
# @param [Hash] hash Options to convert to R format
# @param [Array] keys Acceptable symbols to be converted to R options
# @return [String] R options
def getRopts(hash, keys)
  opts = []
  keys.each do |key|
    if !hash[key].nil?
      hash[key] = "\"#{hash[key]}\"" if hash[key].is_a?(String) # Surround string values in quotes
      opts << "#{key.to_s}=#{hash[key]}"
    end
  end
  return opts.join(", ") # return all options as a string
end

# Gets the elements of a Ruby 2D array and returns
# the elements (in the correct order) to be entered into
# an R matrix. For example:
#
# Ruby matrix:
#
#     x = [[1, 2, 3, 4],
#          [5, 6, 7, 8]]
#
# getRmatrix(x) will return:
#
#     "1, 5, 2, 6, 3, 7, 4, 8" #=> elements
#     2 #=> nrow
#     4 #=> ncol
#
# To be entered into an R matrix as:
#
#     x <- matrix(c(1, 5, 2, 6, 3, 7, 4, 8), nrow=2, ncol=4)
#
# @author Sean Ephraim
# @param [Array] array Array to be converted for R
# @return [Array] R matrix elements, nrow, ncol
def getRmatrix(array)
  nrow = array.length
  ncol = 1
  elements = array
  if array[0].is_a?(Array)
    elements = []
    ncol = array[0].length
    (0..ncol-1).each do |c|
      (0..nrow-1).each do |r|
        elements << array[r][c]
      end
    end
  end
  elements = elements.join(", ")
  return elements,nrow,ncol
end

# Convert R matrix to Ruby matrix.
#
# @param [String] rmatrix R matrix in the form of a string
def getRubyMatrix(rmatrix)
  matrix = []
  rmatrix.split("\n").each_with_index do |line, index|
    next if index == 0 # skip R col index
    vals = line.split("\s")
    vals.shift # remove R row index
    row = []
    vals.each {|val| row << val.to_f}
    matrix << row # add row to Ruby matrix
  end
  return matrix
end

# Method for printing a 2D array. Nice for debugging.
#
# @author Sean Ephraim
# @param [Array] matrix 1D or 2D array to be printed
def printMatrix(matrix)
  matrix.each {|row| print "#{row.to_s}\n"}
end

# Create a filesystem-safe filename. 
# See http://stackoverflow.com/questions/1939333/how-to-make-a-ruby-string-safe-for-a-filesystem#answer-10823131
#
# @author Anders Sjöqvist
# @param [String] filename Name of file
def sanitize_filename(filename)
  # Split the name when finding a period which is preceded by some
  # character, and is followed by some character other than a period,
  # if there is no following period that is followed by something
  # other than a period (yeah, confusing, I know)
  fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

  # We now have one or two parts (depending on whether we could find
  # a suitable period). For each of these parts, replace any unwanted
  # sequence of characters with an underscore
  fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

  # Finally, join the parts with a period and return the result
  return fn.join '.'
end
