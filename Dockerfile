
# Latest stable version of Ubuntu, of course
FROM ubuntu:22.04

LABEL org.opencontainers.image.authors "Leandro Heck <leoheck@gmail.com>, Jacob McSwain <kiri-github-action@mcswain.dev>"
LABEL org.opencontainers.image.description "Kicad 7 and KiRI"
LABEL org.opencontainers.image.url "https://github.com/USA-RedDragon/kiri-github-action/pkgs/container/kiri"
LABEL org.opencontainers.image.documentation "https://github.com/USA-RedDragon/kiri-github-action"
LABEL org.opencontainers.image.source "https://github.com/USA-RedDragon/kiri-github-action"

ARG DEBIAN_FRONTEND noninteractive
ARG DEBCONF_NOWARNINGS="yes"
ENV TERM 'dumb'

RUN apt-get update
RUN apt-get install -y \
		sudo \
		git \
		curl \
		coreutils \
		software-properties-common \
		x11-utils \
		x11-xkb-utils \
		xvfb \
		opam \
		build-essential \
		pkg-config \
		libgmp-dev \
		util-linux \
		python-is-python3 \
		python3-pip \
		dos2unix \
		librsvg2-bin \
		imagemagick \
		xdotool \
		rename \
		bsdmainutils ;\
	apt-get clean ;\
	rm -rf /var/lib/apt/lists/* ;\
	rm -rf /var/tmp/*

# Install latest Kicad
RUN add-apt-repository -y ppa:kicad/kicad-7.0-releases
RUN apt-get install --no-install-recommends -y kicad && \
	apt-get purge -y \
		software-properties-common ;\
	apt-get clean ;\
	rm -rf /var/lib/apt/lists/* ;\
	rm -rf /var/tmp/*

# Create user
RUN useradd -rm -d "/home/github" -s "$(which bash)" -G sudo -u 1001 -U github

# Run sudo without password
RUN echo "github ALL=(ALL) NOPASSWD:ALL" | tee sudo -a "/etc/sudoers"

# Change current user
USER github
WORKDIR "/home/github"
ENV USER github
ENV HOME /home/github
ENV DISPLAY :0

ENV PATH "${PATH}:/home/github/.local/bin"

# Python dependencies
RUN yes | pip3 install \
		"pillow>8.2.0" \
		"six>=1.15.0" \
		"python_dateutil>=2.8.1" \
		"pytz>=2021.1" \
		"pathlib>=1.0.1" && \
	pip3 cache purge

# Opam dependencies
RUN yes | opam init --disable-sandboxing && \
	opam switch create 4.10.2 && \
	eval "$(opam env)" && \
	opam update && \
	opam install -y \
		digestif \
		lwt \
		lwt_ppx \
		cmdliner \
		base64 \
		sha \
		tyxml \
		git-unix ;\
	opam clean -a -c -s --logs -r ;\
	rm -rf ~/.opam/download-cache ;\
	rm -rf ~/.opam/repo/*

# Install kiri, kidiff and plotgitsch
ADD https://api.github.com/repos/USA-RedDragon/kiri/git/refs/heads/main kiri_version.json
ENV KIRI_HOME "/home/github/.local/share/kiri"
RUN git clone --recurse-submodules -j8 https://github.com/USA-RedDragon/kiri.git "${KIRI_HOME}"
RUN cd "${KIRI_HOME}/submodules/plotkicadsch" && \
	opam pin add -y kicadsch . && \
	opam pin add -y plotkicadsch . && \
	opam install -y plotkicadsch; \
	opam clean -a -c -s --logs -r ;\
	rm -rf ~/.opam/download-cache ;\
	rm -rf ~/.opam/repo/*

ENV PATH "${KIRI_HOME}/bin:${KIRI_HOME}/submodules/KiCad-Diff/bin:${PATH}"

# Clean unnecessary stuff
RUN sudo apt-get purge -y \
		curl \
		opam \
		build-essential \
		pkg-config \
		libgmp-dev
RUN sudo apt-get -y autoremove
RUN sudo rm -rf \
		/tmp/* \
		/var/tmp/* \
		/usr/share/doc/* \
		/usr/share/info/* \
		/usr/share/man/*

# Initialize Kicad config files to skip default popups of setup
COPY config "/home/github/.config"
RUN sudo chown -R github:github "/home/github/.config"

COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod a+rx /entrypoint.sh

# GitHub Actions environment variables
ENV KIRI_PROJECT_FILE ""
ENV KIRI_OUTPUT_DIR ""
ENV KIRI_REMOVE ""
ENV KIRI_ARCHIVE ""
ENV KIRI_PCB_PAGE_FRAME ""
ENV KIRI_FORCE_LAYOUT_VIEW ""
ENV KIRI_SKIP_KICAD6_SCHEMATICS ""
ENV KIRI_SKIP_CACHE ""
ENV KIRI_OLDER ""
ENV KIRI_NEWER ""
ENV KIRI_LAST ""
ENV KIRI_ALL ""

ENTRYPOINT ["/entrypoint.sh"]
