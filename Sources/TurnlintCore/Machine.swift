enum EvaluationMode {
  case strict
  case open
  case repair
}

struct EvaluationResult: Equatable {
  let turns: [String]
  let pendingIDs: [String]
  let lastTurnLine: Int?
  let turnCount: Int
  let systemCount: Int
  let userCount: Int
  let assistantCount: Int
  let callCount: Int
  let resultCount: Int
  let peakPendingCount: Int
  let toolCounts: [String: Int]
}

enum Machine {
  static func evaluate(input: String, mode: EvaluationMode, parallel: Int) throws -> EvaluationResult {
    let transcript = try Transcript(input: input)
    var turns: [String] = []
    var pendingIDs: [String] = []
    var calledIDs: Set<String> = []
    var answeredIDs: Set<String> = []
    var previousKind: TurnKind?
    var lastTurnLine: Int?
    var systemCount = 0
    var userCount = 0
    var assistantCount = 0
    var callCount = 0
    var resultCount = 0
    var peakPendingCount = 0
    var toolCounts: [String: Int] = [:]

    for line in transcript.lines {
      guard let turn = try Transcript.parse(line) else { continue }
      let kind = turn.kind

      let completesBeforeTurn =
        !pendingIDs.isEmpty
        && (kind == .user || kind == .assistant || (kind == .call && previousKind == .result))
      if mode == .repair && completesBeforeTurn {
        for id in pendingIDs {
          turns.append("result \(id)")
          answeredIDs.insert(id)
          resultCount += 1
        }
        pendingIDs.removeAll()
        previousKind = .result
      }

      let pending = pendingIDs.joined(separator: ",")

      switch kind {
      case .system:
        guard previousKind == nil else {
          throw failure(turn, "system must be the first turn")
        }
      case .user:
        guard pendingIDs.isEmpty else {
          throw failure(turn, "calls pending: \(pending)")
        }
        if previousKind == .user {
          throw failure(turn, "user follows user")
        }
        if previousKind == .result {
          throw failure(turn, "user follows result")
        }
      case .assistant:
        guard pendingIDs.isEmpty else {
          throw failure(turn, "calls pending: \(pending)")
        }
        if previousKind == nil || previousKind == .system {
          throw failure(turn, "assistant before any user turn")
        }
        if previousKind == .assistant {
          throw failure(turn, "assistant follows assistant")
        }
      case .call:
        if previousKind == nil || previousKind == .system {
          throw failure(turn, "call before any user turn")
        }
        if previousKind == .result && !pendingIDs.isEmpty {
          throw failure(turn, "calls pending: \(pending)")
        }
        let id = turn.words[1]
        if calledIDs.contains(id) {
          throw failure(turn, "duplicate call id \(id)")
        }
        if pendingIDs.count >= parallel {
          throw failure(turn, "too many parallel calls (max \(parallel))")
        }
      case .result:
        let id = turn.words[1]
        guard calledIDs.contains(id) else {
          throw failure(turn, "unknown call id \(id)")
        }
        guard !answeredIDs.contains(id) else {
          throw failure(turn, "call \(id) already has a result")
        }
      }

      turns.append(turn.normalized)
      previousKind = kind
      lastTurnLine = turn.lineNumber
      switch kind {
      case .system:
        systemCount += 1
      case .user:
        userCount += 1
      case .assistant:
        assistantCount += 1
      case .call:
        let id = turn.words[1]
        calledIDs.insert(id)
        pendingIDs.append(id)
        toolCounts[turn.words[2], default: 0] += 1
        callCount += 1
        peakPendingCount = max(peakPendingCount, pendingIDs.count)
      case .result:
        let id = turn.words[1]
        answeredIDs.insert(id)
        pendingIDs.removeAll { $0 == id }
        resultCount += 1
      }
    }

    if mode == .repair {
      for id in pendingIDs {
        turns.append("result \(id)")
        answeredIDs.insert(id)
        resultCount += 1
      }
      pendingIDs.removeAll()
    }

    if mode == .strict, !pendingIDs.isEmpty, let line = lastTurnLine {
      throw Failure(1, "line \(line): calls pending: \(pendingIDs.joined(separator: ","))")
    }

    return EvaluationResult(
      turns: turns,
      pendingIDs: pendingIDs,
      lastTurnLine: lastTurnLine,
      turnCount: turns.count,
      systemCount: systemCount,
      userCount: userCount,
      assistantCount: assistantCount,
      callCount: callCount,
      resultCount: resultCount,
      peakPendingCount: peakPendingCount,
      toolCounts: toolCounts
    )
  }

  private static func failure(_ turn: Turn, _ reason: String) -> Failure {
    Failure(1, "line \(turn.lineNumber): \(reason)")
  }
}
