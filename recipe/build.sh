#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Make path relative to one another.
# No ``realpath --relative-to`` on MacOS.
relpath() {
    to="$(realpath "$1")" || return 1
    from="$(realpath "$2")" || return 1

    common="${from}"
    rel=""
    while [ "${to#"$common"}" = "${to}" ]; do
        common="${common%/*}"
        rel="../${rel}"
    done
    rel="${rel}${to#"$common"/}"
    printf '%s\n' "${rel}"
}

# Replace a symlink by a call to its content
shim_symlink () {
    local path="${1}"
    local path_dir="$(dirname "${path}")"
    local real="$(realpath "${path}")"
    local real_rel_path="$(relpath "${real}" "${path_dir}")"

    echo "Fixing symlink ${path}"

    rm "${path}"
    {
        echo '#!/usr/bin/env bash'
        echo 'here="$(dirname "$(readlink -f "$0")")"'
        echo '"${here}/'"${real_rel_path}"'" "$@"'
    } > "${path}"
    chmod +x "${path}"
}


# Replace all symlinks in ${PREFIX}/ by a shim.
# Windows does not support symlinks without admin so the installer may fail.
find "${PREFIX}/" -type l | while read -r f; do
  shim_symlink "${f}"
done

# Make a windows shim in CMD to a .cmd file
make_win_cmd() {
    out="${1}.cmd"
    base=$(basename "${out%.*}")
    { echo "@\"%~dp0${base}\" %*"; } > "${out}"
}

make_win_cmd "${PREFIX}/bin/vscode-css-language-server"
make_win_cmd "${PREFIX}/bin/vscode-eslint-language-server"
make_win_cmd "${PREFIX}/bin/vscode-html-language-server"
make_win_cmd "${PREFIX}/bin/vscode-json-language-server"
make_win_cmd "${PREFIX}/bin/vscode-markdown-language-server"
