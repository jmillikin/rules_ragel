load("@rules_ragel//ragel:ragel.bzl", "ragel_common")
load("@rules_ragel//ragel/internal:toolchain.bzl", "ragel_toolchain_info")

[ragel_toolchain_info(
    name = "toolchain_v{}".format(version),
    ragel = "@ragel_v{}//bin:ragel".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in ragel_common.VERSIONS]
