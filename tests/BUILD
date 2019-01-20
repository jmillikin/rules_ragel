load("@io_bazel_rules_ragel//ragel:ragel.bzl", "ragel")

ragel(
    name = "hello_cc",
    src = "hello_cc.rl",
    language = "c++",
)

cc_binary(
    name = "hello_cc_bin",
    srcs = [":hello_cc"],
)
