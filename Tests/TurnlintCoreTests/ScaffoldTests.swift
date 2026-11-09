import Testing

@testable import TurnlintCore

@Suite struct ScaffoldTests {
  @Test func loadsTheRegistry() {
    #expect(Registry.version == "0.1.0")
  }
}
