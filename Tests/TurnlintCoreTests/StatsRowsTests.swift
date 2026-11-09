import Testing

@Suite struct StatsRowsTests {
  let rows: [Row] = [
    (["stats"], "", 0, "turns 0\nsystem 0\nuser 0\nassistant 0\ncalls 0\nresults 0\nparallel 0\ntools none\n", ""),
    (["stats"], "system\nuser\nassistant\nuser\n", 0, "turns 4\nsystem 1\nuser 2\nassistant 1\ncalls 0\nresults 0\nparallel 0\ntools none\n", ""),
    (["stats"], "user\ncall a1 search\ncall b2 fetch\nresult b2\nresult a1\nassistant\n", 0, "turns 6\nsystem 0\nuser 1\nassistant 1\ncalls 2\nresults 2\nparallel 2\ntools fetch=1 search=1\n", ""),
    (["stats"], "user\ncall a1 search\ncall b2 fetch\nresult b2\n", 0, "turns 4\nsystem 0\nuser 1\nassistant 0\ncalls 2\nresults 1\nparallel 2\ntools fetch=1 search=1\n", ""),
    (["stats"], "user\ncall a1 search\ncall b2 search\nresult a1\ncall c3 fetch\nresult b2\nresult c3\nassistant\n", 1, "", "turnlint: line 5: calls pending: b2\n"),
    (["stats"], "user\ncall a1 b\nresult a1\ncall b2 a\nresult b2\nassistant\n", 0, "turns 6\nsystem 0\nuser 1\nassistant 1\ncalls 2\nresults 2\nparallel 1\ntools a=1 b=1\n", ""),
    (["stats"], "user\ncall a1 zeta\ncall b2 alpha\ncall c3 _x\n", 0, "turns 4\nsystem 0\nuser 1\nassistant 0\ncalls 3\nresults 0\nparallel 3\ntools _x=1 alpha=1 zeta=1\n", ""),
    (["stats"], "# nothing\n", 0, "turns 0\nsystem 0\nuser 0\nassistant 0\ncalls 0\nresults 0\nparallel 0\ntools none\n", ""),
    (["stats"], "user\nassistant\nuser\nassistant\nuser\n", 0, "turns 5\nsystem 0\nuser 3\nassistant 2\ncalls 0\nresults 0\nparallel 0\ntools none\n", ""),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
