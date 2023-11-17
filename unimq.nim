import std/[os, parseopt, posix, streams, strutils, sequtils, sugar, nre, asyncfile, asyncdispatch]

const help =
  "\n  \e[1;36munimq\e[34m -- print sequentially unique lines, optionally filtering by a specific field(s).\e[0m\n"&
  "\n"&
  "Use case: filter grep output to throw away same-line matches.\n"&
  "\n"&
  "> \e[33mecho '1 2 2 1' | string replace ' ' '\\n' | unimq\e[0m\n"&
  "1\n"&
  "2\n"&
  "1\n"&
  "\n"&
  "> \e[33mecho 'file1:22:33\e[0m\n"&
  "> \e[33mfile1:22:34\e[0m\n"&
  "> \e[33mfile1:44:0' | uniq -d ':' -f '0..2'\e[0m\n"&
  "file1:22:33\n"&
  "file1:44:0\n"&
  "\n"&
  "\e[2mArguments\e[0m:\n"&
  "  -d --delimiter : String      — use a specific delimiter to compare specific fields\n"&
  "  -f --fields : Int | Int..Int — use specific fields to compare given a delimiter\n"&
  "  If arguments are provided at all, both of them must be present."

var delimiterArg = ""
var fieldsArg = ""

var p = initOptParser quoteShellCommand commandLineParams()
while true:
  p.next()
  case p.kind
    of cmdShortOption, cmdLongOption:
      if p.val == "":
        raise newException(OSError, "All options should follow --key=value syntax, got: "&p.key)
      else:
        case p.key
          of "d", "delimiter":
            delimiterArg = p.val
          of "f", "fields":
            fieldsArg = p.val
          of "h", "help":
            echo help; quit 0
    of cmdArgument:
      case p.key
        of "help":
          echo help; quit 0
        else:
          raise newException(OSError, "Unexpected argument "&p.key&help)
    of cmdEnd: break

if delimiterArg != fieldsArg and "" in [ delimiterArg, fieldsArg ]:
  raise newException(OSError, "Fields and delimiter arguments must be supplied together, only got one of them")

proc parseFields(): seq[int] =
  try:
    return @[parseInt fieldsArg]
  except:
    let xs = fieldsArg.split(re"\.\.", maxsplit = 2).map(parseInt)
    if xs.len != 2: raise newException(OSError, "Wrong fields argument "&fieldsArg)
    return xs

proc fieldsOf(fields: seq[int], l: string): seq[string] =
  let lfs = l.split(delimiterArg)
  return fields.map(x => lfs[x])

proc goWholeLine(lines: seq) =
  var prev: string
  for l in lines:
    if l != prev:
      prev = l
      write(stdout, l&"\n")

proc goArgs(lines: seq) =
  var prev: seq = @[""]
  let fields = parseFields()
  for l in lines:
    if l != "":
      let lfs = fieldsOf(fields, l)
      if lfs != prev:
        prev = lfs
        write(stdout, l&"\n")

proc go(lines: seq) =
  if delimiterArg == "" and fieldsArg == "":
    goWholeLine lines
  else:
    goArgs lines

proc main =
  go splitLines waitFor readAll openAsync("/dev/stdin", fmRead)

main()
