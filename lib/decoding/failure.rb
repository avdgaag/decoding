class Decoding::Failure
  def initialize(msg)
    @msg = msg
    @path = []
  end

  def push(segment)
    @path << segment
    self
  end

  def to_s
    if @path.any?
      "Error at .#{@path.reverse.join(".")}: #{@msg}"
    else
      @msg
    end
  end
end
