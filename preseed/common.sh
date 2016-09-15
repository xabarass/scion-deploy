set -e
. /usr/share/debconf/confmodule

log() {
    logger -t scion "$@"
}
