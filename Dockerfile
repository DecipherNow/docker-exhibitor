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
    && if [ $(curl -s -o /dev/null -w "%{http_code}" https://raw.githubusercontent.com/soabase/exhibitor/exhibitor-${EXHIBITOR_VERSION}/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml) -eq "200" ]; then wget https://raw.githubusercontent.com/soabase/exhibitor/exhibitor-${EXHIBITOR_VERSION}/exhibitor-standalone/src/main/resources/buildscripts/standalone/maven/pom.xml -O /exhibitor/pom.xml; else echo "The version provided is invalid"; exit 1; fi
WORKDIR /exhibitor
RUN mvn clean package


FROM alpine:3.8

ARG ZOOKEEPER_VERSION

ENV HOME /home/zookeeper

# Update java settings so DNS changes take hold.
RUN apk add --no-cache openjdk8 curl bash
RUN grep '^networkaddress.cache.ttl=' /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/java.security || echo 'networkaddress.cache.ttl=60' >> /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/java.security

ENV PATH /usr/lib/jvm/java-1.8-openjdk/bin/:$PATH

COPY --from=build /exhibitor/target/exhibitor-*.jar /opt/

RUN \
    # Install zookeeper
    curl -Lo /tmp/zookeeper.tgz https://apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz \
    && mkdir -p /opt/zookeeper \
    && tar -xzf /tmp/zookeeper.tgz -C /tmp \
    && mv /tmp/zookeeper-${ZOOKEEPER_VERSION}/* /opt/zookeeper \
    && rm /tmp/zookeeper.tgz \
    && rm -rf /tmp/zookeeper-${ZOOKEEPER_VERSION} 

RUN mkdir -p /opt/zookeeper/transactions /opt/zookeeper/snapshots /var/lib/zookeeper /opt/exhibitor \
    && chmod -R a+x /opt/zookeeper \
    && chown -R 0:0 /opt /var/lib/zookeeper \
    && chmod -R g=u /opt /var/lib/zookeeper \
    && chown -R 0:0 /bin \
    && chmod -R g=u /bin

RUN mkdir -p /home/zookeeper \
    && chown -R 0:0 /home \
    && chmod -R g=u /home \
    && chmod g=u /etc/passwd

# These are readiness/liveliness probe scripts
COPY zkOk.sh zkMetrics.sh /opt/zookeeper/bin/

ENV EXHIBITOR_JVM_OPTS="-Xmx512m"
ENV ZK_JVM_OPTS="-XX:+PrintCommandLineFlags -XX:+PrintGC -XX:+PrintGCCause -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGCApplicationStoppedTime -XX:+PrintTenuringDistribution -XX:+PrintAdaptiveSizePolicy -Xmx2g -Xms2g -XX:+AlwaysPreTouch -Xss512k"

# Write out basic config
COPY exhibitor-wrapper /exhibitor-wrapper

EXPOSE 2181 2888 3888 8080

USER 1002

CMD ["/exhibitor-wrapper"]

