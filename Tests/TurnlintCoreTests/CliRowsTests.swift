import Testing

@Suite struct CliRowsTests {
  let rows: [Row] = [
    ([], "", 2, "", "usage: turnlint check [--open] [--parallel N]\n       turnlint pending\n       turnlint repair\n       turnlint stats\n"),
    (["help"], "", 0, "usage: turnlint check [--open] [--parallel N]\n       turnlint pending\n       turnlint repair\n       turnlint stats\n", ""),
    (["-h", "extra"], "", 0, "usage: turnlint check [--open] [--parallel N]\n       turnlint pending\n       turnlint repair\n       turnlint stats\n", ""),
    (["--help", "--bogus"], "", 0, "usage: turnlint check [--open] [--parallel N]\n       turnlint pending\n       turnlint repair\n       turnlint stats\n", ""),
    (["--version"], "", 0, "turnlint 0.1.0\n", ""),
    (["--version", "x"], "", 0, "turnlint 0.1.0\n", ""),
    (["frob"], "", 2, "", "turnlint: unknown command frob\n"),
    ([""], "", 2, "", "turnlint: unknown command \n"),
    (["Check"], "", 2, "", "turnlint: unknown command Check\n"),
    (["--open"], "", 2, "", "turnlint: unknown command --open\n"),
    (["--parallel", "2"], "", 2, "", "turnlint: unknown command --parallel\n"),
    (["help", "check"], "", 0, "usage: turnlint check [--open] [--parallel N]\n       turnlint pending\n       turnlint repair\n       turnlint stats\n", ""),
  ]

  @Test func matchesRows() {
    checkRows(rows)
  }
}
