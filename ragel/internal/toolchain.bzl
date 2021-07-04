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

TOOLCHAIN_TYPE = "@rules_ragel//ragel:toolchain_type"

# buildifier: disable=provider-params
RagelToolchainInfo = provider(fields = ["files", "vars", "ragel_executable"])

def _ragel_toolchain_info(ctx):
    toolchain = RagelToolchainInfo(
        ragel_executable = ctx.executable.ragel,
        files = depset(direct = [ctx.executable.ragel]),
        vars = {"RAGEL": ctx.executable.ragel.path},
    )
    return [
        platform_common.ToolchainInfo(ragel_toolchain = toolchain),
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

ragel_toolchain_info = rule(
    _ragel_toolchain_info,
    attrs = {
        "ragel": attr.label(
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
    },
    provides = [
        platform_common.ToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)

def _ragel_toolchain_alias(ctx):
    toolchain = ctx.toolchains[TOOLCHAIN_TYPE].ragel_toolchain
    return [
        DefaultInfo(files = toolchain.files),
        toolchain,
        platform_common.TemplateVariableInfo(toolchain.vars),
    ]

ragel_toolchain_alias = rule(
    _ragel_toolchain_alias,
    toolchains = [TOOLCHAIN_TYPE],
    provides = [
        DefaultInfo,
        RagelToolchainInfo,
        platform_common.TemplateVariableInfo,
    ],
)
