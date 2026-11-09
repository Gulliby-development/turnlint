enum Command {
  case check
  case pending
  case repair
  case stats
}

enum Commands {
  static func execute(command: Command, options: Options, input: String) throws -> String {
    switch command {
    case .check:
      let mode: EvaluationMode = options.open ? .open : .strict
      let result = try Machine.evaluate(input: input, mode: mode, parallel: options.parallel)
      return Report.check(result, open: options.open)
    case .pending:
      let result = try Machine.evaluate(
        input: input,
        mode: .open,
        parallel: Registry.defaultParallel
      )
      return Report.pending(result)
    case .repair:
      let result = try Machine.evaluate(
        input: input,
        mode: .repair,
        parallel: Registry.defaultParallel
      )
      return Report.repair(result)
    case .stats:
      let result = try Machine.evaluate(
        input: input,
        mode: .open,
        parallel: Registry.defaultParallel
      )
      return Report.stats(result)
    }
  }
}
