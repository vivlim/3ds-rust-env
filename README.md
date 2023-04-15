# update 4/14/2023: [there have been updates in the upstream rust3ds since I cobbled this together, so you should probably go there instead!](https://github.com/orgs/rust3ds/)

# Rust on Nintendo 3ds

This repo contains submodules with most of the pieces you need to build 3ds homebrew apps in Rust.

Largely based on work done in [ctru-rs](https://github.com/rust3ds/ctru-rs), ported forward to 2021 Rust by me.

## Why

The sample project is configured (in Cargo.toml and Xargo.toml) to look for ctru-rs, ctru-sys, and Rust (for std) in certain relative paths. Having them all be declared as submodules of this repo standardizes that.

There is almost certainly a better way to do this which doesn't require cross-repo relative path references but for now this works for me.

## Setup

1. Install devkitPro & devkitArm
2. Clone this repo
3. Acquire submodules `git submodule init && git submodule update`
4. Initialize the rust fork repo: `cd rust-3ds-fork && git submodule init && git submodule update`. This will take a long time and use a bunch of disk space.
5. `cd app` (or swap out `app` for your own repo based on it)
6. Install a rust toolchain matching the commit that rust-3ds-fork is based on. Currently that's `rustc 1.53.0-nightly (07e0e2ec2 2021-03-24)`, run something like `rustup override set nightly-2021-03-24`.
7. Install Xargo, `cargo install xargo`
8. `make` will build your project, and if all goes well, you should have a .3dsx file at `target/3ds/release/rust3ds-template.3dsx` which you can then run with the homebrew launcher.

## Tips

`make clean` will remove any build artifacts related to your app.

`make cleanenv` will remove build artifacts related to the rust fork as well, you will want to do this if you've made changes in the fork and want to see them reflected in app.

## Strategy for updating rust-3ds-fork

1. In your app directory, update nightly toolchain with rustup.
    - `rustup toolchain install nightly-2021-03-25`, pick a recent date that has all components from https://rust-lang.github.io/rustup-components-history/
    - `rustup override set nightly-2021-03-25-x86_64-unknown-linux-gnu`
2. `rustup show` to see what commit the toolchain was built from. Note the commit and toolchain version (and probably update this readme while you're at it.)
3. Merge that commit into the fork.
    - `git fetch upstream master`
    - `git checkout -b nightly-2021-03-25`
    - `git merge 07e0e2ec2`
4. Resolve merge conflicts. Make liberal use of conditional compilation (such as `#[cfg(target_os = "horizon")]`) to reduce the amount of drift between the fork code and upstream linux/unix.
    - fix build breaks, I like to do that in a second commit after committing the resolved merge.
5. Update submodules; `git submodule update`
6. `make cleanenv` to clean up the previous rust-3ds-fork, then `make` to rebuild everything.
7. When that all works, update the docker container and this environment:
    - new branch for the nightly, such as `nightly-2021-03-25`. this will become part of the docker image's tag. the name should match the toolchain version, as the Dockerfile will check it out.
        - The docker build checks out the repo again so that it can init and update submodules independent of the outer repo.
    - make sure rust-3ds-fork is committed and pushed
    - update this repo's reference to it
    - update the readme's setup instructions to have the new version
    - update Dockerfile so that has the new toolchain version
    - push and hope it works
8. Update the example app's pipeline to use the new version of the image created & pushed by the github action in step 7
9. Update this repo's submodule reference to the example app. Update this repo's main branch to point to the new nightly.
10. Done!
