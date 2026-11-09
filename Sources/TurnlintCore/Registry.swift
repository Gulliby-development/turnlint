public enum Registry {
  public static let version = "0.1.0"
  public static let maxLines = 60
  public static let defaultParallel = 8
  public static let maxParallel = 16
  public static let commandNames = ["check", "pending", "repair", "stats"]

  public static let usage = """
    usage: turnlint check [--open] [--parallel N]
           turnlint pending
           turnlint repair
           turnlint stats

    """
}

/// The options of one command line: `--open` and `--parallel N` (only `check` takes them).
public struct Options: Equatable {
  public var open = false
  public var parallel = Registry.defaultParallel

  public init() {}
}

/// The result of one command: the exit status and the two streams.
public struct Reply: Equatable {
  public var status: Int32
  public var out: String
  public var err: String

  public init(status: Int32, out: String, err: String) {
    self.status = status
    self.out = out
    self.err = err
  }
}

/// A failure that ends the command: status 1 for the transcript, 2 for the command line.
public struct Failure: Error, Equatable {
  public var status: Int32
  public var message: String

  public init(_ status: Int32, _ message: String) {
    self.status = status
    self.message = message
  }
}
