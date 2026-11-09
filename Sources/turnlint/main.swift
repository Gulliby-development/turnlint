import Foundation
import TurnlintCore

let arguments = Array(CommandLine.arguments.dropFirst())
var input = ""
if Cli.readsStdin(arguments) {
  input = String(decoding: FileHandle.standardInput.readDataToEndOfFile(), as: UTF8.self)
}
let reply = Cli.run(arguments, input: input)
FileHandle.standardOutput.write(Data(reply.out.utf8))
FileHandle.standardError.write(Data(reply.err.utf8))
exit(reply.status)
