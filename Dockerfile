# Image which has both devkitPro/devkitARM as well as rust. based on https://github.com/devkitPro/docker/blob/master/devkitarm/Dockerfile
# parallel build requiring DOCKER_BUILDKIT=1

FROM devkitpro/toolchain-base as base

FROM base as dkp
# workaround for dkp-pacman not able to find /etc/mtab
RUN ln -s /proc/mounts /etc/mtab
RUN dkp-pacman -Syyu --noconfirm 3ds-dev nds-dev gp32-dev gba-dev nds-portlibs && \
    dkp-pacman -S --needed --noconfirm `dkp-pacman -Slq dkp-libs | grep '^3ds-'` && \
    dkp-pacman -Scc --noconfirm

FROM base as env
RUN git clone https://github.com/vivlim/3ds-rust-env.git /build
RUN cd /build && git submodule init && git submodule update
RUN cd /build/rust-3ds-fork && git submodule init && git submodule update

FROM base as rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly-2021-01-30
ENV PATH=${PATH}:/root/.cargo/bin
RUN apt update && apt install build-essential -y
RUN cargo install xargo

# copy in everything from the other 2 images
COPY --from=dkp /opt /opt
COPY --from=env /build /build

ENV DEVKITARM=${DEVKITPRO}/devkitARM

# build the hello world app, resulting in std being built & baked into the image
RUN cd /build/app && make