# nvx
nvx is a tool used to run a contained node version within a project folder.

## Getting started
```bash
# Install nvx
bash .nvx/nvx.sh --install
```

## Usage
```bash
# Instals node (latest version) in project folder.
nvx --node

# Installs node (v8.x.x) in project folder.
nvx --node="8.x"
```

Change to your desired node version. [See available versions at https://nodejs.org/dist/](https://nodejs.org/dist/)

#### Config file
```bash
# Create a .nvxrc file with desired node version.
echo "node_version=8.x" > ".nvxrc"

# Installs node (v8.x.x based on .nvxrc variable) in project folder.
nvx --node
```

## Uninstall
```bash
# Uninstall nvx
bash .nvx/nvx.sh --uninstall
```