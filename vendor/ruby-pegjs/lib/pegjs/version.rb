module Jison
  class Version
    include Comparable

    attr_reader :major, :minor, :micro

    def self.from_string(string)
      version = string.gsub(/^\s+|\s+$/, '').split('.').map(&:to_i)
      new(*version)
    end

    def initialize(major, minor=0, micro=0)
      @major, @minor, @micro = major, minor, micro
    end

    def ==(other)
      major == other.major \
        && minor == other.minor \
        && micro == other.micro
    end

    def <=>(other)
      case other
      when Version
        cmp = major - other.major
        return cmp unless cmp.zero?
        cmp = minor - other.minor
        return cmp unless cmp.zero?
        micro - other.micro
      when String
        self <=> Version.from_string(other)
      when Fixnum
        major - other
      else
        raise RuntimeError.new("Cannot compare against #{other.class}: #{other.inspect}")
      end
    end

    def to_s
      "#{major}.#{minor}.#{micro}"
    end
  end
end
