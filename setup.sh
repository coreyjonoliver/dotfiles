#!/usr/bin/env bash

set -Eeuo pipefail

# Set a restrictive umask so new files are only readable by the user
umask 077

# Disable suspension (Ctrl-Z) since the contents of this script should
# ideally not be interrupted
trap '' TSTP

# Print a friendly message when the user presses Ctrl-C
trap 'trap "" INT; echo "\n\033[0;31mAborting …\033[0m" 1>&2; exit 1' INT

dotfiles_repo_url=${DOTFILES_REPO_URL:-https://github.com/coreyjonoliver/dotfiles}
dotfiles_branch_name=${DOTFILES_BRANCH_NAME:-main}
is_ci=${DOTFILES_IS_CI:-false}
has_no_tty=$(tty >/dev/null 2>&1 && echo false || echo true)
readonly dotfiles_repo_url dotfiles_branch_name is_ci has_no_tty


if [[ $is_ci == true || $has_no_tty == true ]]; then
  no_tty_option="--no-tty"
else
  no_tty_option=""
fi

on_exit() {
    on_exit_hooks+="${on_exit_hooks:+$'\n'}"
    on_exit_hooks+="${*?}"
    # shellcheck disable=SC2064
    trap "${on_exit_hooks}" EXIT
}

function keepalive_sudo_macos() {
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

if ! [[ $is_ci == true || $has_no_tty == true ]]; then
  # We use passwordless sudo in the GitHub workflow, so the keep alive function
  # is not necessary in that scenario
  keepalive_sudo_macos
fi

"$chezmoi_cmd" init "$dotfiles_repo_url" \
  --branch "$dotfiles_branch_name" \
  --use-builtin-git true \
  --apply \
  $no_tty_option

# "$chezmoi_cmd" apply $no_tty_option

on_exit 'printf "\033[0;30mDone.\033[0m\n"'