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

"""Bazel build rules for Ragel.

```python
load("@io_bazel_rules_ragel//:ragel.bzl", "ragel_register_toolchains")
ragel_register_toolchains()
```
"""

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

RAGEL_TOOLCHAIN = "@io_bazel_rules_ragel//ragel:toolchain_type"

RAGEL_VERSIONS = list(_VERSION_URLS)

_SYNTAXES = {
    "c": ("c", "-C"),
    "cpp": ("cc", "-C"),
    "d": ("d", "-D"),
    "go": ("go", "-Z"),
    "java": ("java", "-J"),
    "ruby": ("rb", "-R"),
    "csharp": ("cs", "-A"),
    "ocaml": ("ml", "-O"),
}

def _ragel_lexer(ctx):
    ragel = ctx.toolchains[RAGEL_TOOLCHAIN].ragel

    (ext, syntax_flag) = _SYNTAXES[ctx.attr.syntax]
    out = ctx.actions.declare_file("{}.{}".format(ctx.attr.name, ext))
    dot = ctx.actions.declare_file("{}.dot".format(ctx.attr.name))

    run_common = dict(
        executable = ragel.executable,
        inputs = [ctx.file.src] + ragel.inputs,
        input_manifests = ragel.input_manifests,
        env = ragel.env(ctx),
        mnemonic = "Ragel",
        progress_message = "Generating Ragel lexer {} (from {})".format(ctx.label, ctx.attr.src.label),
    )

    ctx.actions.run(
        arguments = [syntax_flag, "-o", out.path] + ctx.attr.ragel_opts + [ctx.file.src.path],
        outputs = [out],
        **run_common
    )
    ctx.actions.run(
        arguments = ["-V", "-o", dot.path, ctx.file.src.path],
        outputs = [dot],
        **run_common
    )
    return [
        DefaultInfo(files = depset([out])),
        OutputGroupInfo(graphviz = depset([dot])),
    ]

ragel_lexer = rule(
    _ragel_lexer,
    attrs = {
        "src": attr.label(
            mandatory = True,
            single_file = True,
            allow_files = [".rl"],
        ),
        "syntax": attr.string(
            values = list(_SYNTAXES),
            default = "cpp",
        ),
        "ragel_opts": attr.string_list(),
    },
    toolchains = [RAGEL_TOOLCHAIN],
)
"""
```python
load("@io_bazel_rules_ragel//:ragel.bzl", "ragel_lexer")
ragel_lexer(
    name = "hello_cc",
    src = "hello.rl",
)
ragel_lexer(
    name = "hello_go",
    src = "hello.rl",
    syntax = "go",
)
```
"""

def _ragel_env(ctx):
    return {}

def _ragel_toolchain(ctx):
    (inputs, _, input_manifests) = ctx.resolve_command(
        command = "ragel",
        tools = [ctx.attr.ragel],
    )
    return [
        platform_common.ToolchainInfo(
            ragel = struct(
                executable = ctx.executable.ragel,
                inputs = inputs,
                input_manifests = input_manifests,
                env = _ragel_env,
            ),
        ),
    ]

ragel_toolchain = rule(
    _ragel_toolchain,
    attrs = {
        "ragel": attr.label(
            executable = True,
            cfg = "host",
        ),
    },
)

def _check_version(version):
    if version not in _VERSION_URLS:
        fail("Ragel version {} not supported by rules_ragel.".format(repr(version)))

def _ragel_download(ctx):
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

ragel_download = repository_rule(
    _ragel_download,
    attrs = {
        "version": attr.string(mandatory = True),
        "_overlay_v6_BUILD": attr.label(
            default = "//internal:overlay/ragel_v6_BUILD",
            single_file = True,
        ),
        "_overlay_v7_BUILD": attr.label(
            default = "//internal:overlay/ragel_v7_BUILD",
            single_file = True,
        ),
        "_overlay_bin_BUILD": attr.label(
            default = "//internal:overlay/ragel_bin_BUILD",
            single_file = True,
        ),
        "_overlay_colm_BUILD": attr.label(
            default = "//internal:overlay/colm_BUILD",
            single_file = True,
        ),
    },
)

def ragel_register_toolchains(version = _LATEST_STABLE):
    _check_version(version)
    repo_name = "ragel_v{}".format(version)
    if repo_name not in native.existing_rules().keys():
        ragel_download(
            name = repo_name,
            version = version,
        )
    native.register_toolchains("@io_bazel_rules_ragel//toolchains:v{}_toolchain".format(version))
