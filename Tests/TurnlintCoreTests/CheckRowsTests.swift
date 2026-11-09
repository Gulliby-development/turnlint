import Testing

@Suite struct CheckRowsTests {
  let rows: [Row] = [
    (["check"], "", 0, "ok turns 0 calls 0 results 0\n", ""),
    (["check"], "system\nuser\nassistant\nuser\n", 0, "ok turns 4 calls 0 results 0\n", ""),
    (["check"], "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\nassistant\n", 0, "ok turns 6 calls 2 results 2\n", ""),
    (["check"], "user\ncall a1 search\n", 1, "", "turnlint: line 2: calls pending: a1\n"),
    (["check"], "user\ncall a1 search\ncall b2 fetch\nresult b2\n", 1, "", "turnlint: line 4: calls pending: a1\n"),
    (["check", "--open"], "user\ncall a1 search\ncall b2 fetch\nresult b2\n", 0, "ok turns 4 calls 2 results 1\nopen a1\n", ""),
    (["check", "--open"], "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\nassistant\n", 0, "ok turns 6 calls 2 results 2\n", ""),
    (["check", "--open"], "user\ncall a1 search\ncall b2 fetch\n", 0, "ok turns 3 calls 2 results 0\nopen a1,b2\n", ""),
    (["check", "--open"], "# only a comment\n\n", 0, "ok turns 0 calls 0 results 0\n", ""),
    (["check"], "user\ncall a1 search\n\n# note\n", 1, "", "turnlint: line 2: calls pending: a1\n"),
    (["check", "--open"], "user\nassistant\nassistant\n", 1, "", "turnlint: line 3: assistant follows assistant\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
