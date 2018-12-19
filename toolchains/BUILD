load("//:ragel.bzl", "RAGEL_VERSIONS", "ragel_toolchain")

[ragel_toolchain(
    name = "v{}".format(version),
    ragel = "@ragel_v{}//bin:ragel".format(version),
    tags = ["manual"],
    visibility = ["//visibility:public"],
) for version in RAGEL_VERSIONS]

[toolchain(
    name = "v{}_toolchain".format(version),
    toolchain = ":v{}".format(version),
    toolchain_type = "//ragel:toolchain_type",
) for version in RAGEL_VERSIONS]
