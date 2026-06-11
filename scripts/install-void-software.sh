#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=0
YES=0
UPDATE_SYSTEM=1
ENABLE_NONFREE=1

usage() {
    cat <<'EOF'
Usage: install-void-software.sh [options]

Install the Void Linux packages implied by system-software-inventory.txt.

Options:
  -n, --dry-run          Print actions without installing packages
  -y, --yes             Pass -y to xbps-install
      --no-update       Skip the initial system update
      --no-nonfree      Do not enable void-repo-nonfree
  -h, --help            Show this help

Run this after bootstrapping a Void system with network access and sudo.
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=1
            ;;
        -y|--yes)
            YES=1
            ;;
        --no-update)
            UPDATE_SYSTEM=0
            ;;
        --no-nonfree)
            ENABLE_NONFREE=0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

if ! command -v xbps-install >/dev/null 2>&1; then
    echo "xbps-install was not found. Run this script on Void Linux." >&2
    exit 1
fi

SUDO=${SUDO:-sudo}
XBPS_INSTALL_ARGS=(-S)

if [ "$YES" -eq 1 ]; then
    XBPS_INSTALL_ARGS+=(-y)
fi

run() {
    printf '+'
    printf ' %q' "$@"
    printf '\n'

    if [ "$DRY_RUN" -eq 0 ]; then
        "$@"
    fi
}

package_exists() {
    xbps-query -R "$1" >/dev/null 2>&1
}

resolve_spec() {
    local spec="$1"
    local candidate
    local old_ifs="$IFS"

    IFS='|'
    for candidate in $spec; do
        IFS="$old_ifs"
        if package_exists "$candidate"; then
            printf '%s\n' "$candidate"
            return 0
        fi
        IFS='|'
    done

    IFS="$old_ifs"
    return 1
}

install_specs() {
    local group="$1"
    shift

    local spec resolved
    local packages=()
    local missing=()

    for spec in "$@"; do
        if resolved=$(resolve_spec "$spec"); then
            packages+=("$resolved")
        else
            missing+=("$spec")
        fi
    done

    if [ "${#packages[@]}" -gt 0 ]; then
        echo
        echo "==> Installing $group"
        run "$SUDO" xbps-install "${XBPS_INSTALL_ARGS[@]}" "${packages[@]}"
    fi

    if [ "${#missing[@]}" -gt 0 ]; then
        echo
        echo "==> Not found in enabled XBPS repositories for $group"
        printf '    %s\n' "${missing[@]}"
    fi
}

if [ "$UPDATE_SYSTEM" -eq 1 ]; then
    echo "==> Updating XBPS repositories and base system"
    run "$SUDO" xbps-install -Syu
fi

if [ "$ENABLE_NONFREE" -eq 1 ]; then
    echo
    echo "==> Enabling nonfree repository package if available"
    if package_exists void-repo-nonfree; then
        run "$SUDO" xbps-install "${XBPS_INSTALL_ARGS[@]}" void-repo-nonfree
        run "$SUDO" xbps-install -S
    else
        echo "void-repo-nonfree was not found in the current repository set."
    fi
fi

install_specs "base build and CLI tools" \
    base-devel \
    git \
    curl \
    wget \
    patch \
    pkg-config \
    unzip \
    zip \
    tar \
    gzip \
    bzip2 \
    xz \
    sed \
    gawk \
    grep \
    coreutils \
    util-linux \
    psmisc \
    sudo \
    fastfetch \
    tmux \
    fish-shell \
    starship

install_specs "X11 session, dwm dependencies, and desktop utilities" \
    xorg-server \
    xinit \
    xauth \
    xsetroot \
    setxkbmap \
    xkeyboard-config \
    libX11-devel \
    libXft-devel \
    libXinerama-devel \
    libXrandr-devel \
    freetype-devel \
    fontconfig-devel \
    sxhkd \
    dunst \
    rofi \
    maim \
    xclip \
    xdg-utils \
    zathura \
    zathura-pdf-poppler \
    noto-fonts-emoji \
    'font-jetbrains-ttf|font-jetbrains-mono-ttf|nerd-fonts-ttf'

install_specs "terminal, browser, notes, editor, and file tools" \
    wezterm \
    'brave-browser|brave-bin|chromium' \
    obsidian \
    'vscodium|vscodium-bin' \
    neovim \
    yazi \
    poppler-utils \
    ffmpegthumbnailer

install_specs "media, audio, and graphics stack" \
    mpv \
    yt-dlp \
    ffmpeg \
    mesa-vaapi \
    intel-media-driver \
    libva-utils \
    'pulseaudio-utils|pipewire-pulse'

install_specs "language runtimes and editor tooling" \
    lua-language-server \
    clang \
    clang-tools-extra \
    shfmt \
    stylua \
    black \
    python3-isort \
    rust \
    rustfmt \
    go \
    nodejs \
    npm \
    openjdk \
    google-java-format

echo
echo "==> Manual or post-install items"
cat <<'EOF'
- Rebuild local suckless programs after packages are installed:
    ~/dotfiles/scripts/make.sh
- Fisher and fish plugins are managed from fish_plugins, not XBPS.
- Neovim plugins, Mason LSP tooling, eslint_d, prettier, goimports, and some
  formatters may be installed by Neovim/npm/go tooling after first launch.
- envman and tt may need upstream install methods if they are not in your
  enabled Void repositories.
- If Brave, Obsidian, VSCodium, WezTerm, or Yazi were reported missing, check
  whether they are restricted/nonfree or install them through xbps-src/Flatpak.
EOF

echo
echo "Done."
