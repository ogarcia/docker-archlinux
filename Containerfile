FROM docker.io/alpine:3.21 AS bootstrapper
ARG TARGETARCH
ARG PACKAGE_GROUP=base
COPY files /files
RUN \
  apk add arch-install-scripts pacman-makepkg curl && \
  (echo; cat /files/repos-$TARGETARCH; echo; cat /files/noextract) >> /etc/pacman.conf && \
  mkdir -p /etc/pacman.d && \
  . /files/mirrorlist-$TARGETARCH.env && \
  curl -L "$MIRRORLIST_URL" | sed -E 's/^\s*#\s*Server\s*=/Server =/g' > /etc/pacman.d/mirrorlist && \
  if [ -n "$MIRRORLIST_ARCH" ]; then \
    sed -i 's/\$arch/'$MIRRORLIST_ARCH'/g' /etc/pacman.d/mirrorlist; \
  fi && \
  BOOTSTRAP_EXTRA_PACKAGES="" && \
  if [[ "$TARGETARCH" == "arm*" ]]; then \
    EXTRA_KEYRING_FILES=" \
      archlinuxarm-revoked \
      archlinuxarm-trusted \
      archlinuxarm.gpg \
    " && \
    EXTRA_KEYRING_URL="https://raw.githubusercontent.com/archlinuxarm/PKGBUILDs/master/core/archlinuxarm-keyring/" && \
    mkdir /usr/share/pacman/keyrings && \
    for EXTRA_KEYRING_FILE in $EXTRA_KEYRING_FILES; do \
      curl "$EXTRA_KEYRING_URL$EXTRA_KEYRING_FILE" -o /usr/share/pacman/keyrings/$EXTRA_KEYRING_FILE -L; \
    done && \
    BOOTSTRAP_EXTRA_PACKAGES="archlinuxarm-keyring"; \
  else \
    apk add zstd && \
    mkdir /tmp/archlinux-keyring && \
    curl -L https://archlinux.org/packages/core/any/archlinux-keyring/download | unzstd | tar -C /tmp/archlinux-keyring -xv && \
    mv /tmp/archlinux-keyring/usr/share/pacman/keyrings /usr/share/pacman/; \
  fi && \
  pacman-key --init && \
  pacman-key --populate && \
  mkdir /rootfs && \
  /files/pacstrap-docker /rootfs $PACKAGE_GROUP $BOOTSTRAP_EXTRA_PACKAGES && \
  cp /etc/pacman.conf /rootfs/etc/pacman.conf && \
  cp /etc/pacman.d/mirrorlist /rootfs/etc/pacman.d/mirrorlist && \
  echo "en_US.UTF-8 UTF-8" > /rootfs/etc/locale.gen && \
  echo "LANG=en_US.UTF-8" > /rootfs/etc/locale.conf && \
  chroot /rootfs locale-gen && \
  rm -rf /rootfs/var/lib/pacman/sync/* /rootfs/files

FROM scratch AS arch
COPY --from=bootstrapper /rootfs/ /
ENV LANG=en_US.UTF-8
RUN \
  ln -sf /usr/lib/os-release /etc/os-release && \
  pacman-key --init && \
  pacman-key --populate && \
  rm -rf /etc/pacman.d/gnupg/{openpgp-revocs.d/,private-keys-v1.d/,pubring.gpg~,gnupg.S.}*

CMD ["/usr/bin/bash"]
