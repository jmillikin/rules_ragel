# Copyright 2018 the rules_ragel authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

load(
    "@rules_ragel//ragel/internal:toolchain.bzl",
    _TOOLCHAIN_TYPE = "TOOLCHAIN_TYPE",
    _ToolchainInfo = "RagelToolchainInfo",
)

# region Versions {{{

_LATEST_STABLE = "6.10"

_VERSION_URLS = {
    "7.0.0.11": {
        "urls": ["http://www.colm.net/files/ragel/ragel-7.0.0.11.tar.gz"],
        "sha256": "08bac6ff8ea9ee7bdd703373fe4d39274c87fecf7ae594774dfdc4f4dd4a5340",
        "colm": "0.13.0.6",
        "build": "v7",
        "pubdate": "May 2018",
    },
    "6.10": {
        "urls": ["http://www.colm.net/files/ragel/ragel-6.10.tar.gz"],
        "sha256": "5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f",
        "build": "v6",
    },
}

_COLM_URLS = {
    "0.13.0.6": {
        "urls": ["http://www.colm.net/files/colm/colm-0.13.0.6.tar.gz"],
        "sha256": "4644956dd82bedf3795bb1a6fdf9ee8bdd33bd1e7769ef81ffdaa3da70c5a349",
    },
}

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("Ragel version {} not supported by rules_ragel.".format(repr(version)))

# endregion }}}

def ragel_register_toolchains(version = _LATEST_STABLE):
    _check_version(version)
    repo_name = "ragel_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        ragel_repository(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@rules_ragel//ragel/toolchains:v{}".format(version))

ragel_common = struct(
    VERSIONS = list(_VERSION_URLS),
    ToolchainInfo = _ToolchainInfo,
    TOOLCHAIN_TYPE = _TOOLCHAIN_TYPE,
)

# region Build Rules {{{

# region rule(ragel) {{{

_LANGUAGES = {
    "c": ("c", "-C"),
    "c++": ("cc", "-C"),
    "d": ("d", "-D"),
    "go": ("go", "-Z"),
    "java": ("java", "-J"),
    "ruby": ("rb", "-R"),
    "csharp": ("cs", "-A"),
    "ocaml": ("ml", "-O"),
}

def _ragel(ctx):
    ragel_toolchain = ctx.attr._ragel_toolchain[ragel_common.ToolchainInfo]

    (ext, syntax_flag) = _LANGUAGES[ctx.attr.language]
    out_src = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, ext))
    out_dot = ctx.actions.declare_file("{}_report.dot".format(ctx.attr.name))
    out_xml = ctx.actions.declare_file("{}_report.xml".format(ctx.attr.name))

    run_common = dict(
        executable = ragel_toolchain.ragel_executable,
        inputs = depset(
            direct = ctx.files.src + ctx.files.data,
            transitive = [
                ragel_toolchain.files,
            ],
        ),
        mnemonic = "Ragel",
        progress_message = "Generating {}".format(ctx.label),
    )

    # First action: Ragel state machine compilation
    ragel_args = ctx.actions.args()
    ragel_args.add_all([
        syntax_flag,
        "-o",
        out_src.path,
    ])
    ragel_args.add_all(ctx.attr.ragel_options)
    ragel_args.add(ctx.file.src.path)
    ctx.actions.run(
        arguments = [ragel_args],
        outputs = [out_src],
        **run_common
    )

    # Second action: Graphviz graph of machine states
    graph_args = ctx.actions.args()
    graph_args.add_all([
        "-V",
        "-o",
        out_dot.path,
    ])
    graph_args.add_all(ctx.attr.ragel_options)
    graph_args.add(ctx.file.src.path)
    ctx.actions.run(
        arguments = [graph_args],
        outputs = [out_dot],
        **run_common
    )

    # Third action: XML intermediate format for inspection
    report_args = ctx.actions.args()
    report_args.add_all([
        "-x",
        "-o",
        out_xml.path,
    ])
    report_args.add_all(ctx.attr.ragel_options)
    report_args.add(ctx.file.src.path)
    ctx.actions.run(
        arguments = [report_args],
        outputs = [out_xml],
        **run_common
    )

    return [
        DefaultInfo(files = depset(direct = [out_src])),
        OutputGroupInfo(ragel_report = depset(direct = [out_dot, out_xml])),
    ]

ragel = rule(
    _ragel,
    attrs = {
        "src": attr.label(
            mandatory = True,
            allow_single_file = [".rl"],
        ),
        "data": attr.label_list(
            allow_files = True,
        ),
        "ragel_options": attr.string_list(),
        "language": attr.string(
            values = list(_LANGUAGES),
            mandatory = True,
        ),
        "_ragel_toolchain": attr.label(
            default = "@rules_ragel//ragel:toolchain",
        ),
    },
)

# endregion }}}

# endregion }}}

# region Repository Rules {{{

def _ragel_repository(ctx):
    version = ctx.attr.version
    _check_version(version)
    source = _VERSION_URLS[version]

    ctx.download_and_extract(
        url = source["urls"],
        sha256 = source["sha256"],
        stripPrefix = "ragel-{}".format(version),
    )

    if "colm" in source:
        colm = _COLM_URLS[source["colm"]]
        ctx.download_and_extract(
            url = colm["urls"],
            sha256 = colm["sha256"],
            stripPrefix = "colm-{}".format(source["colm"]),
            output = "colm",
        )

    ctx.file("WORKSPACE", "workspace(name = {name})\n".format(name = repr(ctx.name)))
    if source["build"] == "v7":
        ctx.file("src/version.h", """
#undef VERSION
#define VERSION "{}"
#define PUBDATE "{}"
""".format(version, source["pubdate"]))

    build_file = getattr(ctx.attr, "_overlay_{}_BUILD".format(source["build"]))
    ctx.symlink(build_file, "BUILD.bazel")
    ctx.symlink(ctx.attr._overlay_colm_BUILD, "colm/BUILD.bazel")
    ctx.symlink(ctx.attr._overlay_bin_BUILD, "bin/BUILD.bazel")
    ctx.file("stub-config/config.h", "")

ragel_repository = repository_rule(
    _ragel_repository,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_v6_BUILD": attr.label(
            default = "//ragel/internal:overlay/ragel_v6.BUILD",
            allow_single_file = True,
        ),
        "_overlay_v7_BUILD": attr.label(
            default = "//ragel/internal:overlay/ragel_v7.BUILD",
            allow_single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "//ragel/internal:overlay/ragel_bin.BUILD",
            allow_single_file = True,
        ),
        "_overlay_colm_BUILD": attr.label(
            default = "//ragel/internal:overlay/colm.BUILD",
            allow_single_file = True,
        ),
    },
)

# endregion }}}
