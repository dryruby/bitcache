module Enumerable

  # Returns a new array containing the results of running +block+
  # concurrently (in separate threads) for every element in +enum+.
  def map_concurrently(&block)
    threads = []
    each { |item| threads << Thread.new(item, &block) } 
    threads.map { |thread| thread.value }
  end

end
