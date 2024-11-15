FROM docker.io/alpine:3.20 AS bootstrapper
ARG TARGETARCH
ARG PACKAGE_GROUP=base
COPY files /files
RUN \
  apk add arch-install-scripts pacman-makepkg curl && \
  (echo; cat /files/repos-$TARGETARCH; echo; cat /files/noextract) >> /etc/pacman.conf && \
  mkdir -p /etc/pacman.d && \
  cp /files/mirrorlist-$TARGETARCH /etc/pacman.d/mirrorlist && \
  BOOTSTRAP_EXTRA_PACKAGES="" && \
  if [[ "$TARGETARCH" == "arm*" ]]; then \
    ALARM_MIRROR="http://mirror.archlinuxarm.org" && \
    mkdir /tmp/archlinuxarm-core /tmp/archlinuxarm-keyring && \
    curl -L $ALARM_MIRROR/aarch64/core/core.db.tar.gz | tar -xvz -C /tmp/archlinuxarm-core && \
    KEYRING_PACKAGE_FILENAME="$(grep -A1 "%FILENAME%" /tmp/archlinuxarm-core/archlinuxarm-keyring-*/desc | tail -n 1)" && \
    curl -L $ALARM_MIRROR/aarch64/core/$KEYRING_PACKAGE_FILENAME > /tmp/$KEYRING_PACKAGE_FILENAME && \
    tar -xvaf /tmp/$KEYRING_PACKAGE_FILENAME -C /tmp/archlinuxarm-keyring && \
    mkdir /usr/share/pacman/keyrings && \
    mv /tmp/archlinuxarm-keyring/usr/share/pacman/keyrings/* /usr/share/pacman/keyrings/ && \
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
