# Usage

Use these rules to generate lexers and parsers using
[Ragel](https://www.colm.net/open-source/ragel/). Add something like this to
your Bazel `WORKSPACE`:

```python
# You may wish to change the git commit in the url (and the sha256).
http_archive(
    name = "rules_ragel",
    url = "https://github.com/jmillikin/rules_ragel/archive/f99f17fcad2e155646745f4827ac636a3b5d4d15.zip",
    sha256 = "f957682c6350b2e4484c433c7f45d427a86de5c8751a0d2a9836f36995fe0320",
    strip_prefix = "rules_ragel-f99f17fcad2e155646745f4827ac636a3b5d4d15",
)

# Load rules_ragel
load("@rules_ragel//ragel:ragel.bzl", "ragel_register_toolchains")

# Register a ragel 6.10 toolchain:
ragel_register_toolchains()

# Or to use ragel 7:
# ragel_register_toolchains("7.0.0.11")
```

Then your `BUILD` file might look something like this:

```python
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")
load("@rules_ragel//ragel:ragel.bzl", "ragel")

package(default_visibility = ["//visibility:public"])

# Ragel lexer, defined in file lexer.rl
ragel(
    name = "lexer",
    src = "lexer.rl",
    language = "c++",
)

# Library built from the lexer; in a complete example you'd likely have other
# hdrs and srcs listed in this rule.
cc_library(
    name = "lib",
    srcs = [":lexer"],
)

# Build a binary that uses the lexer.
cc_binary(
    name = "program",
    srcs = ["main.cc"],
    deps = [":lib"],
)
```

For more details refer to the `ragel/ragel.bzl` file, and the tests in the
`tests/` directory.
