import Testing

@Suite struct PendingRowsTests {
  let rows: [Row] = [
    (["pending"], "", 0, "none\n", ""),
    (["pending"], "system\nuser\nassistant\nuser\n", 0, "none\n", ""),
    (["pending"], "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\nassistant\n", 0, "none\n", ""),
    (["pending"], "user\ncall a1 search\ncall b2 fetch\nresult b2\n", 0, "a1\n", ""),
    (["pending"], "user\ncall a1 search\ncall b2 fetch\ncall c3 calc\nresult b2\n", 0, "a1\nc3\n", ""),
    (["pending"], "user\ncall a1 search\nresult a1\ncall b2 fetch\n", 0, "b2\n", ""),
    (["pending"], "user\ncall a1 search\nuser\n", 1, "", "turnlint: line 3: calls pending: a1\n"),
    (["pending"], "user\ncall a1 search\nresult b2\n", 1, "", "turnlint: line 3: unknown call id b2\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
