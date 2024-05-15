# Container images for Arch Linux

[![forthebadge](https://forthebadge.com/images/badges/powered-by-black-magic.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/gluten-free.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/works-on-my-machine.svg)](https://forthebadge.com)

(c) 2017-2024 Óscar García Amor

This repository contains all the scripts and files needed to create various
container image flavors of the Arch Linux distribution.

Strongly based on [Menci's work][menci].

[menci]: https://github.com/Menci/docker-archlinuxarm

## About tags

At this moment, two images of Arch Linux are building.

- **base**: default image with basic system.
- **devel**: the basic system with base-devel package group.

Tag format used is as following.

- **base**: `YYYY.MM.DD`, `YYYY.MM.DD-base`, `base`, `latest`
- **devel**: `YYYY.MM.DD-devel`, `devel`

Old images are archived with format `YYYY.MM.DD` and `YYYY.MM.DD-base` for
base and `YYYY.MM.DD-devel` for devel.

Visit [GitLab][gl], [Quay][quay] or [Docker Hub][dh] to see all available
tags.

[gl]: https://gitlab.com/ogarcia/container-archlinux/container_registry
[quay]: https://quay.io/repository/ogarcia/archlinux
[dh]: https://hub.docker.com/r/ogarcia/archlinux/
