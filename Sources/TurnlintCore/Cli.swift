public enum Cli {
  public static func run(_ args: [String], input: String) -> Reply {
    switch parse(args) {
    case let .reply(reply):
      return reply
    case let .command(command, options):
      do {
        return Reply(status: 0, out: try Commands.execute(command: command, options: options, input: input), err: "")
      } catch let failure as Failure {
        return Reply(status: failure.status, out: "", err: "turnlint: \(failure.message)\n")
      } catch {
        return Reply(status: 1, out: "", err: "turnlint: internal error\n")
      }
    }
  }

  public static func readsStdin(_ args: [String]) -> Bool {
    if case .command = parse(args) { return true }
    return false
  }

  private enum ParseResult {
    case command(Command, Options)
    case reply(Reply)
  }

  private static func parse(_ args: [String]) -> ParseResult {
    guard let first = args.first else {
      return .reply(Reply(status: 2, out: "", err: Registry.usage))
    }
    if ["help", "-h", "--help"].contains(first) {
      return .reply(Reply(status: 0, out: Registry.usage, err: ""))
    }
    if first == "--version" {
      return .reply(Reply(status: 0, out: "turnlint \(Registry.version)\n", err: ""))
    }
    guard Registry.commandNames.contains(first) else {
      return .reply(commandError("unknown command \(first)"))
    }

    let command: Command
    switch first {
    case "check": command = .check
    case "pending": command = .pending
    case "repair": command = .repair
    default: command = .stats
    }

    var options = Options()
    var sawOpen = false
    var sawParallel = false
    var index = 1
    while index < args.count {
      let word = args[index]
      if first != "check" {
        if word.isEmpty || word == "-" || !word.hasPrefix("-") {
          return .reply(commandError("unexpected argument \(word)"))
        }
        return .reply(commandError("unknown option \(word)"))
      }
      switch word {
      case "--open":
        guard !sawOpen else { return .reply(commandError("given twice: --open")) }
        sawOpen = true
        options.open = true
        index += 1
      case "--parallel":
        guard !sawParallel else { return .reply(commandError("given twice: --parallel")) }
        sawParallel = true
        index += 1
        guard index < args.count else {
          return .reply(commandError("missing value for --parallel"))
        }
        guard let value = parallelValue(args[index]) else {
          return .reply(commandError("bad value for --parallel"))
        }
        options.parallel = value
        index += 1
      default:
        if word.isEmpty || word == "-" || !word.hasPrefix("-") {
          return .reply(commandError("unexpected argument \(word)"))
        }
        return .reply(commandError("unknown option \(word)"))
      }
    }
    return .command(command, options)
  }

  private static func parallelValue(_ word: String) -> Int? {
    guard let first = word.utf8.first, first >= 49, first <= 57,
      word.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
      let value = Int(word), value <= Registry.maxParallel
    else { return nil }
    return value
  }

  private static func commandError(_ message: String) -> Reply {
    Reply(status: 2, out: "", err: "turnlint: \(message)\n")
  }
}
