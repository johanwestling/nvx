![NVX](./docs/logo.png)

NVX enables you to run a contained version of Node.js within a project directory.

## Prerequisites
* Terminal with bash & git support

## Getting started
```bash
# Clone nvx to your project path
git clone https://github.com/johanwestling/nvx.git

# Install nvx
bash nvx/install/install.sh

# Run nvx to see available commands
nvx
```

## Usage
```bash
# Instals node (latest version) in project folder.
nvx --enable

# Installs node (v8.x.x) in project folder.
nvx --enable="8.x"
```

Change to your desired node version. [See available versions at https://nodejs.org/dist/](https://nodejs.org/dist/)

#### Config file
```bash
# Create a .nvxrc file with desired node version.
echo "node_version=8.x" > ".nvxrc"

# Installs node (v8.x.x based on .nvxrc variable) in project folder.
nvx --enable
```

## Uninstall
```bash
# Uninstall nvx
nvx --uninstall
```
