class ApplicationService
  def initialize(*args)
    # Default implementation does nothing, can be overridden in subclasses
  end
  def self.call(*args)
    new(*args).call
  end

  def call
    raise NotImplementedError, "#{self.class} does not implement ##{__method__}"
  end
end
