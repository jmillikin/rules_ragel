load("//ragel:ragel.bzl", "ragel_common")

[toolchain(
    name = "v{}".format(version),
    toolchain = "//ragel/internal:toolchain_v{}".format(version),
    toolchain_type = ragel_common.TOOLCHAIN_TYPE,
) for version in ragel_common.VERSIONS]
