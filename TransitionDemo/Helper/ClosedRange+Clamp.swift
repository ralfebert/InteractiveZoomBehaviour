extension ClosedRange {

    /** If the given value is in the range, the value is returned. Otherwise the nearest lower/upper bound is returned.
     */
    func clamp(_ value: Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }

}

extension ClosedRange where Bound: FloatingPoint {

    func clampedFraction(value : Bound) -> Bound {
        return (0 ... 1).clamp(value / (upperBound - lowerBound))
    }

}
