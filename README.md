# unimq

A small CLI program to read from the standard input and output consequent unique lines like `uniq`, but without needing to sort them and with ability to specify a field (or a range of fields) to determine uniqueness.

### Usage

#### Arguments

  **-d --delimiter**="your char/string here"
    Specify the delimiter to use. Note that if this option is used, `--fields` **must** be used as well.

  **-f --fields**="0" ="3" ="0..2" ="1..4"
    Specify the fields to use. Note that if this option is used, `--delimiter` **must** be used as well.

  **-h --help help**
    Print out available options and some usage examples.

Or use it without arguments to uniq by whole lines.

#### Examples

```shell
# Just get unique consecutive lines like you would with `uniq`
> echo "1
2
1
3
3
1" | unimq
1
2
1
3
1

# Specify a field
> echo "file1:10:0
file2:10:2
file1:5:3
file3:10:22
file4:10:11
file3:15:5" | unimq --delimiter=":" --fields="1"
file1:10:0
file1:5:3
file3:10:22
file3:15:5

# Specify a range of fields
> echo "file1:10:0
file1:10:20
file1:13:1" | unimq --delimiter=":" --fields="0..1"
file1:10:0
file1:13:1
```

