module Motion
  class Layout
    LAYOUT_FORMAT_OPTIONS = {
      left: NSLayoutFormatAlignAllLeft,
      right: NSLayoutFormatAlignAllRight,
      top: NSLayoutFormatAlignAllTop,
      bottom: NSLayoutFormatAlignAllBottom,
      leading: NSLayoutFormatAlignAllLeading,
      trailing: NSLayoutFormatAlignAllTrailing,
      center_x: NSLayoutFormatAlignAllCenterX,
      center_y: NSLayoutFormatAlignAllCenterY,
      baseline: NSLayoutFormatAlignAllBaseline,
      mask: NSLayoutFormatAlignmentMask,
      leading_to_trailing: NSLayoutFormatDirectionLeadingToTrailing,
      left_to_right: NSLayoutFormatDirectionLeftToRight,
      right_to_left: NSLayoutFormatDirectionRightToLeft,
      direction_mask: NSLayoutFormatDirectionMask
    }
    
    def initialize(&block)
      @verticals   = []
      @horizontals = []
      @metrics     = {}

      yield self
      strain
    end

    def metrics(metrics)
      @metrics = Hash[metrics.keys.map(&:to_s).zip(metrics.values)]
    end

    def subviews(subviews)
      @subviews = Hash[subviews.keys.map(&:to_s).zip(subviews.values)]
    end

    def view(view)
      @view = view
    end

    def horizontal(horizontal, *options)
      @horizontals << [horizontal, options_bitmask(*options)]
    end

    def vertical(vertical, *options)
      @verticals << [vertical, options_bitmask(*options)]
    end
    
    def options_bitmask(*options)
      options.map { |o| o.is_a?(Integer) ? o : LAYOUT_FORMAT_OPTIONS[o] || 0 }.inject(:|)
    end

    private

    def strain
      @subviews.values.each do |subview|
        subview.translatesAutoresizingMaskIntoConstraints = false
        @view.addSubview(subview)
      end

      constraints = []
      constraints += @verticals.map do |vertical, options|
        NSLayoutConstraint.constraintsWithVisualFormat("V:#{vertical}", options: options, metrics:@metrics, views:@subviews)
      end
      constraints += @horizontals.map do |horizontal, options|
        NSLayoutConstraint.constraintsWithVisualFormat("H:#{horizontal}", options: options, metrics:@metrics, views:@subviews)
      end

      @view.addConstraints(constraints.flatten)
    end
  end
end
