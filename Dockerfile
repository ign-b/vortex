# Build Stage
FROM rust:1.81.0 AS build
USER 0:0
WORKDIR /home/rust

RUN apt-get update && apt-get install -y python3 python3-pip
RUN USER=root cargo new --bin vortex
WORKDIR /home/rust/vortex

RUN rustup component add rustfmt
COPY Cargo.toml Cargo.lock ./
RUN cargo build --locked --release

RUN rm src/*.rs target/release/deps/vortex*
COPY src ./src
RUN cargo install --locked --path .

# Bundle Stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y libc6
COPY --from=build /usr/local/cargo/bin/vortex ./vortex

EXPOSE 8080
ENV HTTP_HOST 0.0.0.0:8080

CMD ["./vortex"]
