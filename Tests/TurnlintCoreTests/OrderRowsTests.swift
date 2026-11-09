import Testing

@Suite struct OrderRowsTests {
  let rows: [Row] = [
    (["check"], "", 0, "ok turns 0 calls 0 results 0\n", ""),
    (["check"], "system\nuser\nassistant\nuser\n", 0, "ok turns 4 calls 0 results 0\n", ""),
    (["check"], "user\nsystem\n", 1, "", "turnlint: line 2: system must be the first turn\n"),
    (["check"], "system\nsystem\n", 1, "", "turnlint: line 2: system must be the first turn\n"),
    (["check"], "assistant\n", 1, "", "turnlint: line 1: assistant before any user turn\n"),
    (["check"], "system\nassistant\n", 1, "", "turnlint: line 2: assistant before any user turn\n"),
    (["check"], "user\nuser\n", 1, "", "turnlint: line 2: user follows user\n"),
    (["check"], "user\nassistant\nassistant\n", 1, "", "turnlint: line 3: assistant follows assistant\n"),
    (["check"], "call a1 search\n", 1, "", "turnlint: line 1: call before any user turn\n"),
    (["check"], "system\ncall a1 search\n", 1, "", "turnlint: line 2: call before any user turn\n"),
    (["check"], "user\ncall a1 search\nresult a1\nuser\n", 1, "", "turnlint: line 4: user follows result\n"),
    (["check"], "user\ncall a1 search\nuser\n", 1, "", "turnlint: line 3: calls pending: a1\n"),
    (["check"], "user\ncall a1 search\nassistant\n", 1, "", "turnlint: line 3: calls pending: a1\n"),
    (["check"], "user\nassistant\ncall a1 search\nresult a1\nassistant\nuser\n", 0, "ok turns 6 calls 1 results 1\n", ""),
    (["check"], "user\ncall a1 search\nresult a1\ncall b2 fetch\nresult b2\nassistant\n", 0, "ok turns 6 calls 2 results 2\n", ""),
    (["check"], "user\ncall a1 search\ncall b2 fetch\nresult a1\ncall c3 calc\n", 1, "", "turnlint: line 5: calls pending: b2\n"),
    (["check"], "system\nuser\nassistant\ncall a1 calc\nresult a1\n", 0, "ok turns 5 calls 1 results 1\n", ""),
    (["check"], "# c\n\nuser\n\n# d\nuser\n", 1, "", "turnlint: line 6: user follows user\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
