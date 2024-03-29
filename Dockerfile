# Image which has both devkitPro/devkitARM as well as rust. based on https://github.com/devkitPro/docker/blob/master/devkitarm/Dockerfile
# parallel build requiring DOCKER_BUILDKIT=1

FROM devkitpro/devkitarm as base
ENV RUST_TOOLCHAIN nightly-2021-03-25

FROM base as env
RUN git clone https://github.com/vivlim/3ds-rust-env.git /build --single-branch --branch ${RUST_TOOLCHAIN}
RUN cd /build && git submodule init && git submodule update
RUN cd /build/rust-3ds-fork && git submodule init && git submodule update

FROM base as rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain ${RUST_TOOLCHAIN}
ENV PATH=${PATH}:/root/.cargo/bin
RUN apt update && apt install build-essential -y
RUN cargo install xargo

# copy in everything from the other image
COPY --from=env /build /build

ENV DEVKITARM=${DEVKITPRO}/devkitARM

# build the hello world app, resulting in std being built & baked into the image
RUN cd /build/app && make