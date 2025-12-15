#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/vscode-css-language-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/vscode-langservers-extracted/bin/vscode-css-language-server "\$@"
EOF
chmod +x ${PREFIX}/bin/vscode-css-language-server

tee ${PREFIX}/bin/vscode-eslint-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/vscode-langservers-extracted/bin/vscode-eslint-server "\$@"
EOF
chmod +x ${PREFIX}/bin/vscode-eslint-server

tee ${PREFIX}/bin/vscode-json-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/vscode-langservers-extracted/bin/vscode-json-server "\$@"
EOF
chmod +x ${PREFIX}/bin/vscode-json-server

tee ${PREFIX}/bin/vscode-markdown-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/vscode-langservers-extracted/bin/vscode-markdown-server "\$@"
EOF
chmod +x ${PREFIX}/bin/vscode-markdown-server

tee ${PREFIX}/bin/vscode-css-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\vscode-langservers-extracted\bin\vscode-css-language-server "\$@"
EOF

tee ${PREFIX}/bin/vscode-eslint-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\vscode-langservers-extracted\bin\vscode-eslint-server "\$@"
EOF

tee ${PREFIX}/bin/vscode-json-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\vscode-langservers-extracted\bin\vscode-json-server "\$@"
EOF

tee ${PREFIX}/bin/vscode-markdown-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\vscode-langservers-extracted\bin\vscode-markdown-server "\$@"
EOF
