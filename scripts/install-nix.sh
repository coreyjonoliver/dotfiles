#!/usr/bin/env bash

set -eu
umask 077

cleanup () {
    set +u
    rm -fr "$gpg_homedir" "$install_dir"
    set -u
}

trap "cleanup" EXIT HUP INT TERM

usage () {
    echo "Usage: $0" >&2
    exit 1
}

if [[ $# != 0 ]]; then
    usage
fi

readonly install_dir="$(mktemp -d "${TMPDIR:-/tmp}/install-nix-install.XXXXXXXX")"
readonly data_file="${install_dir}/install-nix-2.3.15"
readonly sig="${install_dir}/install-nix-2.3.15.asc"

readonly gpg_homedir="$(mktemp -d "${TMPDIR:-/tmp}/install-nix-verify-sig.XXXXXXXX")"
readonly keyring="$(mktemp "${gpg_homedir}/tmp.XXXXXXXX.gpg")"

curl \
    --silent \
    -o "$sig" https://releases.nixos.org/nix/nix-2.3.15/install.asc
curl \
    --silent \
    -o "$data_file" https://releases.nixos.org/nix/nix-2.3.15/install
    
gpg \
     --dearmor - << __EOF > "$keyring"
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
qXy2HtxyhCn9+V8ki5G/znEJwor48g==
=Mc2q
-----END PGP PUBLIC KEY BLOCK-----
__EOF

verify_sig() {
    if [[ -x "$(command -v gpgv)" ]]; then
        gpgv \
            --homedir "$gpg_homedir" \
            --keyring "$keyring" \
            "$sig" \
            "$data_file" 2>&1
    elif [[ -x "$(command -v gpg)" ]]; then
        gpg \
            --no-options \
            --no-default-keyring \
            -q \
            --verify \
            --homedir "$gpg_homedir" \
            --keyring "$keyring" \
            "$sig" \
            "$data_file" 2>&1
    else
        echo "cannot verify signature on nix since GnuPG is not installed" >&2
        exit 1
    fi
}

if ! gpg_output=$(verify_sig); then
    printf "%s" "$gpg_output"
    echo
    echo "cannot verify signature"
    exit 1
fi

chmod +x "$data_file"
"$data_file" --darwin-use-unencrypted-nix-store-volume
