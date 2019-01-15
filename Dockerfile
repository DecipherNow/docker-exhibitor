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

FROM maven:3-jdk-8-alpine as build

LABEL MAINTAINER=chris.smith@deciphernow.com \
    PRODUCT=exhibitor

ARG EXHIBITOR_VERSION

RUN mkdir exhibitor \
    && wget https://raw.githubusercontent.com/Netflix/exhibitor/master/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml -O /exhibitor/pom.xml \
    && sed -i "s/1.6.0/${EXHIBITOR_VERSION}/g" /exhibitor/pom.xml
WORKDIR /exhibitor
RUN mvn clean package


FROM openjdk:8-jdk-slim
ARG ZOOKEEPER_VERSION
# Update java settings so DNS changes take hold.
RUN apt-get update && apt-get install -y --no-install-recommends curl netcat net-tools
RUN grep '^networkaddress.cache.ttl=' /etc/java-8-openjdk/security/java.security || echo 'networkaddress.cache.ttl=60' >> /etc/java-8-openjdk/security/java.security
COPY --from=build /exhibitor/target/exhibitor-*.jar /opt/

RUN \
    # Install zookeeper
    curl -Lo /tmp/zookeeper.tgz https://apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz \
    && mkdir -p /opt/zookeeper/transactions /opt/zookeeper/snapshots /var/lib/zookeeper /opt/exhibitor \
    && tar -xzf /tmp/zookeeper.tgz -C /opt/zookeeper --strip=1 \
    && rm /tmp/zookeeper.tgz \
    && chmod a+x /opt/exhibitor-*.jar \
    && chgrp -R 0 /var/lib/zookeeper \
    && chmod -R g=u /var/lib/zookeeper \
    && chgrp -R 0 /opt \
    && chmod -R g=u /opt \ 
    && rm -rf /var/lib/apt/lists/*

# These are readiness/liveliness probe scripts
COPY zkOk.sh zkMetrics.sh /opt/zookeeper/bin/

COPY entrypoint /entrypoint

# Write out basic config
COPY exhibitor-wrapper /exhibitor-wrapper

USER 1002

ENTRYPOINT ["/entrypoint"]
