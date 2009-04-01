require 'RMagick'
require 'tempfile'

module HTMLRender; end

module HTMLRender::Images
  class Base
    def ==(other)
      return false unless self.class === other
      (self <=> other) == 0
    end

    def difference(other)
      raise NotImplementedError
    end
  end

  class PNGImage < Base
    attr_reader :png

    def initialize(data)
      @png = Magick::Image.from_blob(data)[0]
    end

    def <=>(other)
      self.class.name <=> other.class.name unless PNGImage === other
      png <=> other.png
    end

    def difference(other)
      raise NotImplementedError unless PNGImage === other

      rows = [ png.rows, other.png.rows ].max
      columns = [ png.columns, other.png.columns ].max

      image = Magick::Image.new(columns, rows) do |info|
        info.format = 'png'
      end
      image.background_color = 'black'
      image.composite!(png, 0, 0, Magick::OverCompositeOp)
      image.composite!(other.png, 0, 0, Magick::DifferenceCompositeOp)
    end

    def to_blob
      png.to_blob
    end
  end
end
