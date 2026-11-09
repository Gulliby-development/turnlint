struct PhysicalLine: Equatable {
  let number: Int
  let text: String
}

enum TurnKind: String, Equatable {
  case system
  case user
  case assistant
  case call
  case result
}

struct Turn: Equatable {
  let kind: TurnKind
  let words: [String]
  let lineNumber: Int

  var normalized: String {
    words.joined(separator: " ")
  }
}

struct Transcript {
  let lines: [PhysicalLine]

  init(input: String) throws {
    let bytes = Array(input.utf8)
    guard !bytes.isEmpty else {
      lines = []
      return
    }

    var physicalLines: [PhysicalLine] = []
    var start = 0
    for index in bytes.indices where bytes[index] == 10 {
      let end = index > start && bytes[index - 1] == 13 ? index - 1 : index
      let lineBytes = bytes[start..<end]
      physicalLines.append(
        PhysicalLine(number: physicalLines.count + 1, text: String(decoding: lineBytes, as: UTF8.self))
      )
      start = index + 1
    }
    if start < bytes.count {
      let lineBytes = bytes[start..<bytes.count]
      physicalLines.append(
        PhysicalLine(number: physicalLines.count + 1, text: String(decoding: lineBytes, as: UTF8.self))
      )
    }

    guard physicalLines.count <= Registry.maxLines else {
      throw Failure(1, "transcript is too long (max \(Registry.maxLines) lines)")
    }
    lines = physicalLines
  }

  static func parse(_ line: PhysicalLine) throws -> Turn? {
    let words = splitWords(line.text)
    guard let first = words.first else { return nil }
    if first.hasPrefix("#") { return nil }

    guard let kind = TurnKind(rawValue: first) else {
      throw lineFailure(line, "unknown turn \(first)")
    }

    let expectedCount = kind == .call ? 3 : (kind == .result ? 2 : 1)
    guard words.count == expectedCount else {
      throw lineFailure(line, "bad arguments for \(first)")
    }

    if kind == .call || kind == .result {
      let id = words[1]
      guard isValidID(id) else {
        throw lineFailure(line, "bad id \(id)")
      }
    }
    if kind == .call {
      let tool = words[2]
      guard isValidToolName(tool) else {
        throw lineFailure(line, "bad tool name \(tool)")
      }
    }

    return Turn(kind: kind, words: words, lineNumber: line.number)
  }

  private static func splitWords(_ text: String) -> [String] {
    let bytes = Array(text.utf8)
    var result: [String] = []
    var start: Int?
    for index in bytes.indices {
      if bytes[index] == 32 || bytes[index] == 9 {
        if let wordStart = start {
          result.append(String(decoding: bytes[wordStart..<index], as: UTF8.self))
          start = nil
        }
      } else if start == nil {
        start = index
      }
    }
    if let wordStart = start {
      result.append(String(decoding: bytes[wordStart..<bytes.count], as: UTF8.self))
    }
    return result
  }

  private static func isValidID(_ value: String) -> Bool {
    let bytes = Array(value.utf8)
    guard (1...8).contains(bytes.count) else { return false }
    return bytes.allSatisfy { byte in
      (byte >= 97 && byte <= 122) || (byte >= 48 && byte <= 57)
    }
  }

  private static func isValidToolName(_ value: String) -> Bool {
    let bytes = Array(value.utf8)
    guard (1...12).contains(bytes.count) else { return false }
    return bytes.allSatisfy { byte in
      (byte >= 97 && byte <= 122) || byte == 95
    }
  }

  private static func lineFailure(_ line: PhysicalLine, _ reason: String) -> Failure {
    Failure(1, "line \(line.number): \(reason)")
  }
}
