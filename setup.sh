#!/bin/sh

# dotfiles initialization script
# Use chezmoi for unattended initilziation of dotfiles.

set -euo

# Set a restrictive umask so new files are only readable by the user.
umask 077

LOG_LEVEL=2
DOTFILES_REPO_URL=${DOTFILES_REPO_URL:-https://github.com/coreyjonoliver/dotfiles}
DOTFILES_BRANCH_NAME=${DOTFILES_BRANCH_NAME:-main}
IS_CI=${DOTFILES_IS_CI:-false}
HAS_NO_TTY=$(tty >/dev/null 2>&1 && echo false || echo true)

if [ "$IS_CI" = true ] || [ "$HAS_NO_TTY" = true ]; then
  NO_TTY_OPTION="--no-tty"
else
  NO_TTY_OPTION=""
fi

usage() {
	this="${1}"
	cat <<EOF
${this}: initialize dotfiles

Usage: ${this}
EOF
	exit 2
}

on_exit() {
  if [ -n "$on_exit_hooks" ]; then
    on_exit_hooks="$on_exit_hooks\n"
  else
      on_exit_hooks=""
  fi
  on_exit_hooks="$on_exit_hooks${*?}"
  # shellcheck disable=SC2064
  trap "${on_exit_hooks}" INT EXIT
}

main() {
  if [ "$#" -ne 1 ]; then
    usage "${0}"
  fi

  # Prevent system sleep
  /usr/bin/caffeinate -dimu -w $$ &

  chezmoi_bin_dir="$(mktemp -d)"
  readonly chezmoi_bin_dir
  on_exit "
    printf '\033[0;31mDeleting chezmoi bin directory …\033[0m\n'
    rm -fr '$chezmoi_bin_dir'
  "

  printf '\033[0;34mDownloading chezmoi …\033[0m\n'
  BINDIR="$chezmoi_bin_dir" sh -c "$(curl -fsLS get.chezmoi.io)"

  chezmoi_cmd="$chezmoi_bin_dir/chezmoi"
  readonly chezmoi_cmd

  if [ "$IS_CI" != true ] && [ "$HAS_NO_TTY" != true ]; then
    # We want to ensure that during the lifetime of the script, authentication
    # doesn't automatically expire after some timespan of sudo inactivity. Note,
    # this is not needed for GitHub Actions since it uses passwordless sudo.
    keepalive_sudo_macos
  fi

  "$chezmoi_cmd" init "$DOTFILES_REPO_URL" \
    --branch "$DOTFILES_BRANCH_NAME" \
    --use-builtin-git true \
    --apply \
    $NO_TTY_OPTION

  # "$chezmoi_cmd" apply $NO_TTY_OPTION

  on_exit 'printf "\033[0;30mDone.\033[0m\n"'
}

keepalive_sudo_macos() {
    # ref. https://github.com/reitermarkus/dotfiles/blob/7f19deb970dc943540512c94cb8742bf9b4509ae/.sh
    (
      builtin read -r -s -p "Password: " < /dev/tty
      builtin echo "add-generic-password -U -s 'dotfiles' -a '${USER}' -w '${REPLY}'"
    ) | /usr/bin/security -i
    printf "\n"

    on_exit "
      echo '\033[0;31mRemoving password from Keychain …\033[0m'
      /usr/bin/security delete-generic-password -s 'dotfiles' -a '${USER}'
    "

    SUDO_ASKPASS="$(/usr/bin/mktemp)"

    on_exit "
      printf '\033[0;31mDeleting SUDO_ASKPASS script …\033[0m\n'
      /bin/rm -f '${SUDO_ASKPASS}'
    "

    {
      echo "#!/bin/sh"
      echo "/usr/bin/security find-generic-password -s 'dotfiles' -a '${USER}' -w"
    } > "${SUDO_ASKPASS}"

    /bin/chmod +x "${SUDO_ASKPASS}"

    export SUDO_ASKPASS

    if ! /usr/bin/sudo -A -kv 2>/dev/null; then
      printf '\033[0;31mIncorrect password.\033[0m\n' 1>&2
      exit 1
    fi
}

log_debug() {
  [ 3 -le "${LOG_LEVEL}" ] || return 0
  printf 'debug %s\n' "${*}" 1>&2
}

log_info() {
  [ 2 -le "${LOG_LEVEL}" ] || return 0
  printf 'info %s\n' "${*}" 1>&2
}

log_err() {
  [ 1 -le "${LOG_LEVEL}" ] || return 0
  printf 'error %s\n' "${*}" 1>&2
}

log_crit() {
  [ 0 -le "${LOG_LEVEL}" ] || return 0
  printf 'critical %s\n' "${*}" 1>&2
}

main "${@}"

# TODO: Use logging functions
# TODO: Use -b instead of BINDIR in chezmoi command
# TODO: Could possibly use --purge-binary instead of a tmpdir?