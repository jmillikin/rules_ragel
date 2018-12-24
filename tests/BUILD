load("//:ragel.bzl", "ragel_machine")

ragel_machine(
    name = "hello_cc",
    src = "hello_cc.rl",
)

cc_binary(
    name = "hello_cc_bin",
    srcs = [":hello_cc"],
)
