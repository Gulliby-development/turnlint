import Testing

@Suite struct ReadsRowsTests {
  let rows: [Row] = [
    (["help"], "", 0, "", ""),
    (["-h"], "", 0, "", ""),
    ([], "", 0, "", ""),
    (["frob"], "", 0, "", ""),
    (["check"], "", 1, "", ""),
    (["check", "--open"], "", 1, "", ""),
    (["check", "--parallel", "4", "--open"], "", 1, "", ""),
    (["pending"], "", 1, "", ""),
    (["repair"], "", 1, "", ""),
    (["stats"], "", 1, "", ""),
    (["stats", "--open"], "", 0, "", ""),
    (["check", "--parallel"], "", 0, "", ""),
    (["check", "x"], "", 0, "", ""),
    (["--version"], "", 0, "", ""),
    (["check", "--parallel", "17"], "", 0, "", ""),
    (["pending", "--parallel", "2"], "", 0, "", ""),
  ]

  @Test func matchesRows() {
    checkReads(rows)
  }
}
