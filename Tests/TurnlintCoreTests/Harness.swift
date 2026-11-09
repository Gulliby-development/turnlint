import Testing

@testable import TurnlintCore

/// A row of a row file: the arguments, the input text, then the expected status, standard output and standard error.
/// In a `readsStdin` row the status is 1 when the command line must read standard input and 0 when not.
typealias Row = (args: [String], input: String, status: Int32, out: String, err: String)

func checkRows(_ rows: [Row], sourceLocation: SourceLocation = #_sourceLocation) {
  for (index, row) in rows.enumerated() {
    let reply = Cli.run(row.args, input: row.input)
    #expect(reply.status == row.status, "row \(index + 1): status", sourceLocation: sourceLocation)
    #expect(reply.out == row.out, "row \(index + 1): out", sourceLocation: sourceLocation)
    #expect(reply.err == row.err, "row \(index + 1): err", sourceLocation: sourceLocation)
  }
}

func checkReads(_ rows: [Row], sourceLocation: SourceLocation = #_sourceLocation) {
  for (index, row) in rows.enumerated() {
    let reads = Cli.readsStdin(row.args)
    #expect(reads == (row.status == 1), "row \(index + 1): readsStdin", sourceLocation: sourceLocation)
  }
}
