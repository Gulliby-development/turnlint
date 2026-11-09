import Testing

@Suite struct CallRowsTests {
  let rows: [Row] = [
    (["check"], "user\ncall a1 search\nresult a1\nassistant\n", 0, "ok turns 4 calls 1 results 1\n", ""),
    (["check"], "user\ncall a1 search\ncall a1 fetch\n", 1, "", "turnlint: line 3: duplicate call id a1\n"),
    (["check"], "user\ncall a1 search\nresult a1\ncall a1 search\n", 1, "", "turnlint: line 4: duplicate call id a1\n"),
    (["check"], "user\nresult a1\n", 1, "", "turnlint: line 2: unknown call id a1\n"),
    (["check"], "user\ncall a1 search\nresult b2\n", 1, "", "turnlint: line 3: unknown call id b2\n"),
    (["check"], "user\ncall a1 search\nresult a1\nresult a1\n", 1, "", "turnlint: line 4: call a1 already has a result\n"),
    (["check"], "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\nassistant\n", 0, "ok turns 6 calls 2 results 2\n", ""),
    (["check", "--parallel", "2"], "user\ncall a1 search\ncall b2 fetch\ncall c3 calc\n", 1, "", "turnlint: line 4: too many parallel calls (max 2)\n"),
    (["check", "--parallel", "2"], "user\ncall a1 search\ncall b2 fetch\nresult a1\ncall c3 calc\n", 1, "", "turnlint: line 5: calls pending: b2\n"),
    (["check", "--parallel", "1"], "user\ncall a1 search\ncall b2 fetch\n", 1, "", "turnlint: line 3: too many parallel calls (max 1)\n"),
    (["check", "--parallel", "3"], "user\ncall a1 search\ncall b2 fetch\ncall c3 calc\nresult c3\nresult b2\nresult a1\nassistant\n", 0, "ok turns 8 calls 3 results 3\n", ""),
    (["check"], "user\ncall a1 s\ncall b2 s\ncall c3 s\ncall d4 s\ncall e5 s\ncall f6 s\ncall g7 s\ncall h8 s\ncall i9 s\n", 1, "", "turnlint: line 10: too many parallel calls (max 8)\n"),
    (["check"], "user\ncall a1 s\ncall b2 s\ncall c3 s\ncall d4 s\ncall e5 s\ncall f6 s\ncall g7 s\ncall h8 s\n", 1, "", "turnlint: line 9: calls pending: a1,b2,c3,d4,e5,f6,g7,h8\n"),
    (["check", "--parallel", "16"], "user\ncall c1 s\ncall c2 s\ncall c3 s\ncall c4 s\ncall c5 s\ncall c6 s\ncall c7 s\ncall c8 s\ncall c9 s\ncall c10 s\ncall c11 s\ncall c12 s\ncall c13 s\ncall c14 s\ncall c15 s\ncall c16 s\n", 1, "", "turnlint: line 17: calls pending: c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16\n"),
    (["check", "--parallel", "16"], "user\ncall c1 s\ncall c2 s\ncall c3 s\ncall c4 s\ncall c5 s\ncall c6 s\ncall c7 s\ncall c8 s\ncall c9 s\ncall c10 s\ncall c11 s\ncall c12 s\ncall c13 s\ncall c14 s\ncall c15 s\ncall c16 s\ncall c17 s\n", 1, "", "turnlint: line 18: too many parallel calls (max 16)\n"),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
