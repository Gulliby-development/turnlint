import Testing

@Suite struct RepairRowsTests {
  let rows: [Row] = [
    (["repair"], "", 0, "", ""),
    (["repair"], "system\nuser\nassistant\nuser\n", 0, "system\nuser\nassistant\nuser\n", ""),
    (["repair"], "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\nassistant\n", 0, "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\nassistant\n", ""),
    (["repair"], "user\ncall a1 search\ncall b2 fetch\nresult b2\n", 0, "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\n", ""),
    (["repair"], "user\ncall a1 search\ncall b2 fetch\nassistant\n", 0, "user\ncall a1 search\ncall b2 fetch\nresult a1\nresult b2\nassistant\n", ""),
    (["repair"], "user\ncall a1 search\nresult a1\ncall b2 fetch\nresult b2\n", 0, "user\ncall a1 search\nresult a1\ncall b2 fetch\nresult b2\n", ""),
    (["repair"], "user\ncall a1 search\ncall b2 fetch\nresult b2\ncall c3 calc\nassistant\n", 0, "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\ncall c3 calc\nresult c3\nassistant\n", ""),
    (["repair"], "user\ncall a1 search\nuser\n", 1, "", "turnlint: line 3: user follows result\n"),
    (["repair"], "user\ncall a1 search\nsystem\n", 1, "", "turnlint: line 3: system must be the first turn\n"),
    (["repair"], "  user  \n# gone\n\ncall   a1\tsearch\n", 0, "user\ncall a1 search\nresult a1\n", ""),
    (["repair"], "user\ncall a1 search\ncall b2 fetch\nresult a1\nuser\n", 1, "", "turnlint: line 5: user follows result\n"),
    (["repair"], "user\ncall a1 search\ncall a1 fetch\n", 1, "", "turnlint: line 3: duplicate call id a1\n"),
    (["repair"], "user\ncall a1 search\nassistant\ncall b2 fetch\n", 0, "user\ncall a1 search\nresult a1\nassistant\ncall b2 fetch\nresult b2\n", ""),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
