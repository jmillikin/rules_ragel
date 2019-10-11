workspace(name = "rules_ragel")

load("@rules_ragel//ragel:ragel.bzl", "ragel_register_toolchains", "ragel_repository")
load("@rules_ragel//ragel/internal:versions.bzl", "VERSION_URLS")

ragel_register_toolchains()

[ragel_repository(
    name = "ragel_v" + version,
    version = version,
) for version in VERSION_URLS]
