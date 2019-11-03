workspace(name = "rules_ragel")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_ragel//ragel:ragel.bzl", "ragel_register_toolchains", "ragel_repository")
load("@rules_ragel//ragel/internal:versions.bzl", "VERSION_URLS")

ragel_register_toolchains()

[ragel_repository(
    name = "ragel_v" + version,
    version = version,
) for version in VERSION_URLS]

http_archive(
    name = "com_google_googletest",
    sha256 = "9bf1fe5182a604b4135edc1a425ae356c9ad15e9b23f9f12a02e80184c3a249c",
    strip_prefix = "googletest-release-1.8.1",
    urls = ["https://github.com/google/googletest/archive/release-1.8.1.tar.gz"],
)
