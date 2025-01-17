struct Formatter {
  enum DataUnits: String, CaseIterable {
    case bytes = "B"
    case kilobytes = "K"
    case megabytes = "M"
    case gigabytes = "G"
    case terabytes = "T"
    case petabytes = "P"
  }

  static func formatByteString(value: Int) -> String {
    func format(_ value: Float, _ unit: DataUnits) -> String {
      "\(String(format: "%.1f" , currentValue))\(unit.rawValue)"
    }

    var currentValue = Float(value)
    for unit in DataUnits.allCases {
      if currentValue >= 1024 {
        currentValue = currentValue / 1024.0
      } else {
        return format(currentValue, unit)
      }
    }
    return format(currentValue, DataUnits.allCases[-1])
  }
}
