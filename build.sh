#!/bin/bash

# Copyright 2019 Decipher Technology Studios
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

EXHIBITOR_VERSION="${1:-$(cat EXHIBITOR_VERSION)}"
ZOOKEEPER_VERSION="${2:-$(cat ZOOKEEPER_VERSION)}"


EX_MAJOR="$(echo ${EXHIBITOR_VERSION} | awk -F '[\.\-]' '{print $1}')"
EX_MINOR="$(echo ${EXHIBITOR_VERSION} | awk -F '[\.\-]' '{print $2}')"
EX_PATCH="$(echo ${EXHIBITOR_VERSION} | awk -F '[\.\-]' '{print $3}')"

ZK_MAJOR="$(echo ${ZOOKEEPER_VERSION} | awk -F '[\.\-]' '{print $1}')"
ZK_MINOR="$(echo ${ZOOKEEPER_VERSION} | awk -F '[\.\-]' '{print $2}')"
ZK_PATCH="$(echo ${ZOOKEEPER_VERSION} | awk -F '[\.\-]' '{print $3}')"

docker build . \
    --build-arg "ZOOKEEPER_VERSION=${ZOOKEEPER_VERSION}" \
    --build-arg "EXHIBITOR_VERSION=${EXHIBITOR_VERSION}" \
    -t "deciphernow/exhibitor:${EX_MAJOR}-${ZK_MAJOR}" \
    -t "deciphernow/exhibitor:${EX_MAJOR}.${EX_MINOR}-${ZK_MAJOR}.${ZK_MINOR}" \
    -t "deciphernow/exhibitor:${EX_MAJOR}.${EX_MINOR}.${EX_PATCH}-${ZK_MAJOR}.${ZK_MINOR}.${ZK_PATCH}" 