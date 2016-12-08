class Cache

  @data
  def def initialize

    @data[:test] = "test"
  end
  def set ( key, value )
    @data[key] = value
  end

  def get ( key )
    return @data.fetch( key )
  end

  def exists ( key )
    @data = Hash.new
    if @data.fetch( key, nil ) != nil
      return true
    else
      return false
    end
  end

end
