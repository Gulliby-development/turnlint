import Testing

@Suite struct OptionsRowsTests {
  let rows: [Row] = [
    (["check", "x"], "", 2, "", "turnlint: unexpected argument x\n"),
    (["check", ""], "", 2, "", "turnlint: unexpected argument \n"),
    (["pending", "-"], "", 2, "", "turnlint: unexpected argument -\n"),
    (["stats", "--open"], "", 2, "", "turnlint: unknown option --open\n"),
    (["repair", "--parallel", "2"], "", 2, "", "turnlint: unknown option --parallel\n"),
    (["pending", "--nope"], "", 2, "", "turnlint: unknown option --nope\n"),
    (["check", "--open", "--open"], "", 2, "", "turnlint: given twice: --open\n"),
    (["check", "--parallel"], "", 2, "", "turnlint: missing value for --parallel\n"),
    (["check", "--parallel", "0"], "", 2, "", "turnlint: bad value for --parallel\n"),
    (["check", "--parallel", "007"], "", 2, "", "turnlint: bad value for --parallel\n"),
    (["check", "--parallel", "17"], "", 2, "", "turnlint: bad value for --parallel\n"),
    (["check", "--parallel", "16"], "", 0, "ok turns 0 calls 0 results 0\n", ""),
    (["check", "--parallel", "x"], "", 2, "", "turnlint: bad value for --parallel\n"),
    (["check", "--parallel", "2", "--parallel", "3"], "", 2, "", "turnlint: given twice: --parallel\n"),
    (["check", "--parallel", "--open"], "", 2, "", "turnlint: bad value for --parallel\n"),
    (["check", "--open", "--parallel", "1", "x"], "", 2, "", "turnlint: unexpected argument x\n"),
    (["check", "--parallel", "2", "--open"], "user\n", 0, "ok turns 1 calls 0 results 0\n", ""),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
