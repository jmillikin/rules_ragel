load("@rules_ragel//ragel:ragel.bzl", "ragel")
load("@rules_ragel//ragel/internal:versions.bzl", "VERSION_URLS")

genrule(
    name = "genrule_test",
    srcs = ["hello_cc.rl"],
    outs = ["genrule_output.cc"],
    cmd = """
$(RAGEL) -C -o $@ $(location hello_cc.rl)
""",
    toolchains = [
        "@rules_ragel//ragel:toolchain",
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

filegroup(
    name = "testdata",
    srcs = [
        ":genrule_test",
        ":hello_cc_bin",
    ],
)

cc_test(
    name = "ragel_test",
    srcs = ["ragel_test.cc"],
    data = [":testdata"],
    deps = [
        "@bazel_tools//tools/cpp/runfiles",
        "@com_google_googletest//:gtest",
        "@com_google_googletest//:gtest_main",
    ],
)

filegroup(
    name = "all_versions",
    srcs = [
        "@ragel_v{}//bin:ragel".format(version)
        for version in VERSION_URLS
    ],
    tags = ["manual"],
)
