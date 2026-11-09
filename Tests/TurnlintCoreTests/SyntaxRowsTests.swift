import Testing

@Suite struct SyntaxRowsTests {
  let rows: [Row] = [
    (["check"], "frob\n", 1, "", "turnlint: line 1: unknown turn frob\n"),
    (["check"], "User\n", 1, "", "turnlint: line 1: unknown turn User\n"),
    (["check"], "user now\n", 1, "", "turnlint: line 1: bad arguments for user\n"),
    (["check"], "call a1\n", 1, "", "turnlint: line 1: bad arguments for call\n"),
    (["check"], "call a1 search now\n", 1, "", "turnlint: line 1: bad arguments for call\n"),
    (["check"], "result\n", 1, "", "turnlint: line 1: bad arguments for result\n"),
    (["check"], "result a1 a2\n", 1, "", "turnlint: line 1: bad arguments for result\n"),
    (["check"], "user\ncall A1 search\n", 1, "", "turnlint: line 2: bad id A1\n"),
    (["check"], "user\ncall abcdefghi search\n", 1, "", "turnlint: line 2: bad id abcdefghi\n"),
    (["check"], "user\ncall a1 Search\n", 1, "", "turnlint: line 2: bad tool name Search\n"),
    (["check"], "user\ncall a1 se-arch\n", 1, "", "turnlint: line 2: bad tool name se-arch\n"),
    (["check"], "user\ncall a1 search\nresult a-1\n", 1, "", "turnlint: line 3: bad id a-1\n"),
    (["check"], "# note\n\n  \nuser\nfrob\n", 1, "", "turnlint: line 5: unknown turn frob\n"),
    (["check"], "user\r\nassistant\r\nbogus\r\n", 1, "", "turnlint: line 3: unknown turn bogus\n"),
    (["check"], "\tuser\t\n  assistant  \n", 0, "ok turns 2 calls 0 results 0\n", ""),
    (["check"], "user # first\n", 1, "", "turnlint: line 1: bad arguments for user\n"),
    (["check"], "user\ncall a1 abcdefghijkl\nresult a1\nassistant\n", 0, "ok turns 4 calls 1 results 1\n", ""),
    (["check"], "user\ncall a1 abcdefghijklm\n", 1, "", "turnlint: line 2: bad tool name abcdefghijklm\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
