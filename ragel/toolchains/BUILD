load("@rules_ragel//ragel:ragel.bzl", "ragel_common")

[toolchain(
    name = "v{}".format(version),
    toolchain = "@rules_ragel//ragel/internal:toolchain_v{}".format(version),
    toolchain_type = ragel_common.TOOLCHAIN_TYPE,
) for version in ragel_common.VERSIONS]
