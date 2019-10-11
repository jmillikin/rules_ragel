# Copyright 2019 the rules_ragel authors.
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

DEFAULT_VERSION = "6.10"

_MIRRORS = [
    "https://mirror.bazel.build/www.colm.net/files/",
    "https://distfiles.macports.org/",
    "https://mirrors.aliyun.com/macports/distfiles/",
    "http://www.colm.net/files/",
]

def _urls(filename):
    return [m + filename for m in _MIRRORS]

VERSION_URLS = {
    "7.0.0.11": {
        "urls": _urls("ragel/ragel-7.0.0.11.tar.gz"),
        "sha256": "08bac6ff8ea9ee7bdd703373fe4d39274c87fecf7ae594774dfdc4f4dd4a5340",
        "colm": "0.13.0.6",
        "build": "v7",
        "pubdate": "May 2018",
    },
    "6.10": {
        "urls": _urls("ragel/ragel-6.10.tar.gz"),
        "sha256": "5f156edb65d20b856d638dd9ee2dfb43285914d9aa2b6ec779dac0270cd56c3f",
        "build": "v6",
    },
}

COLM_URLS = {
    "0.13.0.6": {
        "urls": _urls("colm/colm-0.13.0.6.tar.gz"),
        "sha256": "4644956dd82bedf3795bb1a6fdf9ee8bdd33bd1e7769ef81ffdaa3da70c5a349",
    },
}

def check_version(version):
    if version not in VERSION_URLS:
        fail("Ragel version {} not supported by rules_ragel.".format(repr(version)))
