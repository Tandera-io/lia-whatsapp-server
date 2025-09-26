FROM node:22.19.0-alpine AS base
WORKDIR /usr/src/wpp-server
ENV NODE_ENV=production \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    SHARP_IGNORE_GLOBAL_LIBVIPS=1 \
    npm_config_target_platform=linuxmusl \
    npm_config_target_arch=x64 \
    npm_config_target_libc=musl
COPY package.json .dockernpmrc ./
RUN cp .dockernpmrc .npmrc
RUN apk update && \
    apk add --no-cache \
    vips-dev \
    fftw-dev \
    gcc \
    g++ \
    make \
    libc6-compat \
    pkgconfig \
    python3 \
    py3-pip \
    && rm -rf /var/cache/apk/*
RUN yarn install --production --pure-lockfile && \
    npm install --platform=linuxmusl --arch=x64 sharp && \
    yarn cache clean

FROM base AS build
WORKDIR /usr/src/wpp-server
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
COPY package.json  ./
RUN yarn install --production=false --pure-lockfile
RUN yarn cache clean
COPY . .
RUN yarn build

FROM base
WORKDIR /usr/src/wpp-server/
RUN apk add --no-cache chromium
RUN yarn cache clean
COPY . .
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/
EXPOSE 21465
ENTRYPOINT ["node", "dist/server.js"]
