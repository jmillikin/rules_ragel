cc_library(
    name = "config_h",
    hdrs = glob(["stub-config/*.h"]),
    includes = ["stub-config"],
    visibility = ["//bin:__pkg__"],
)

cc_library(
    name = "aapl",
    hdrs = glob(["aapl/*.h"]),
    strip_include_prefix = "aapl",
)

cc_library(
    name = "ragel_lib",
    srcs = glob([
        "ragel/*.cpp",
        "ragel/*.h",
    ]),
    visibility = ["//bin:__pkg__"],
    deps = [
        ":aapl",
        ":config_h",
    ],
)
