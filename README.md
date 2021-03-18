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
4. Initialize the rust fork repo: `cd rust-3ds-fork; ./x.py`. Tests may fail to run, but you can ignore that.
5. `cd app` (or swap out `app` for your own repo based on it)
6. Install a rust toolchain matching the commit that rust-3ds-fork is based on. Currently that's `rustc 1.51.0-nightly (04caa632d 2021-01-30)`, run something like `rustup override set nightly-2021-01-30`.
7. `make` will build your project, and if all goes well, you should have a .3dsx file at `target/3ds/release/rust3ds-template.3dsx` which you can then run with the homebrew launcher.

## Tips

`make clean` will remove any build artifacts related to your app.

`make cleanenv` will remove build artifacts related to the rust fork as well, you will want to do this if you've made changes in the fork and want to see them reflected in app.

## Strategies for updating rust-3ds-fork

I haven't had to revisit it yet to do this, but something like the following should work:

1. In your app directory, update nightly toolchain with rustup.
2. `rustup show` to see what commit the toolchain was built from. Note the commit and toolchain version (and probably update this readme while you're at it.)
3. Merge that commit into the fork.
4. Resolve merge conflicts. Make liberal use of conditional compilation (such as `#[cfg(target_os = "horizon")]`) to reduce the amount of drift between the fork code and upstream linux/unix.
5. `make cleanenv` to clean up the previous rust-3ds-fork, then `make` to rebuild everything.
