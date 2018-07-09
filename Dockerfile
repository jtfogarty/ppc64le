ARG IMAGE=ubuntu:16.04
FROM $IMAGE

ARG GO_VERSION=1.10.3
ARG BAZEL_RELEASE=0.11.1

RUN apt-get update && apt-get install -y build-essential openjdk-8-jdk python zip
RUN apt-get install -y curl wget
RUN mkdir bazel
WORKDIR bazel
# RUN wget -O bazel-${BAZEL_RELEASE}-dist.zip https://github.com/bazelbuild/bazel/releases/download/${BAZEL_RELEASE}/bazel-${BAZEL_RELEASE}-dist.zip
RUN curl -fSL -o bazel-${BAZEL_RELEASE}-dist.zip https://github.com/bazelbuild/bazel/releases/download/${BAZEL_RELEASE}/bazel-${BAZEL_RELEASE}-dist.zip
RUN unzip -q bazel-$BAZEL_RELEASE-dist.zip && \
    ./compile.sh
ENV PATH=$PATH:/bazel/output/

# CLEAN UP LATER -- things needed for building envoy
RUN apt-get update && apt-get install -y git cmake automake wget libtool m4 sudo vim-tiny

# update go. this version's way too old and buggy for some architectures
RUN set -eux; \
    \
    arch="$(uname -m)"; \
    case "${arch##*-}" in \
        x86_64 | amd64) ARCH='amd64' ;; \
        ppc64el | ppc64le) ARCH='ppc64le' ;; \
        *) echo "unsupported architecture"; exit 1 ;; \
    esac; \
    wget -nv -O - https://storage.googleapis.com/golang/go${GO_VERSION}.linux-${ARCH}.tar.gz \
    | tar -C /usr/local -xz

RUN bazel version