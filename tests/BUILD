load("@io_bazel_rules_ragel//ragel:ragel.bzl", "ragel")

genrule(
    name = "genrule_test",
    srcs = ["hello_cc.rl"],
    outs = ["genrule_output.cc"],
    cmd = """
$(RAGEL) -C -o $@ $(location hello_cc.rl)
""",
    toolchains = [
        "@io_bazel_rules_ragel//ragel:toolchain",
    ],
)

ragel(
    name = "hello_cc",
    src = "hello_cc.rl",
    language = "c++",
)

cc_binary(
    name = "hello_cc_bin",
    srcs = [":hello_cc"],
)
