enum Report {
  static func check(_ result: EvaluationResult, open: Bool) -> String {
    var output =
      "ok turns \(result.turnCount) calls \(result.callCount) results \(result.resultCount)\n"
    if open, !result.pendingIDs.isEmpty {
      output += "open \(result.pendingIDs.joined(separator: ","))\n"
    }
    return output
  }

  static func pending(_ result: EvaluationResult) -> String {
    guard !result.pendingIDs.isEmpty else { return "none\n" }
    return result.pendingIDs.map { "\($0)\n" }.joined()
  }

  static func stats(_ result: EvaluationResult) -> String {
    let tools: String
    if result.toolCounts.isEmpty {
      tools = "none"
    } else {
      let names = result.toolCounts.keys.sorted {
        $0.utf8.lexicographicallyPrecedes($1.utf8)
      }
      tools = names.map { "\($0)=\(result.toolCounts[$0] ?? 0)" }.joined(separator: " ")
    }

    return """
      turns \(result.turnCount)
      system \(result.systemCount)
      user \(result.userCount)
      assistant \(result.assistantCount)
      calls \(result.callCount)
      results \(result.resultCount)
      parallel \(result.peakPendingCount)
      tools \(tools)
      """ + "\n"
  }

  static func repair(_ result: EvaluationResult) -> String {
    result.turns.map { "\($0)\n" }.joined()
  }
}
