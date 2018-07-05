# nvx
nvx is a tool used to run a contained node version within a project folder.

## Usage

#### Enable node in current command line session
```bash
# Enables node in current session (will download & enable latest node version if first run).
source ./nvx.sh
```

#### Enable a specific node version in current command line session
```bash
# Enables node 8.x.x in current session (will download if desired version is not present in .nvx folder).
source ./nvx.sh "8.x"
```

Change to your desired node version. [See available versions at https://nodejs.org/dist/](https://nodejs.org/dist/)

#### Provide a set version based on config file
```bash
# Create a .nvxrc file with desired node version.
echo "node_version=8.x" > ".nvxrc"

# Enables node 8.x.x (based on .nvxrc) in current session (will download if desired version is not present in .nvx folder).
source ./nvx.sh
```

Change to your desired node version. [See available versions at https://nodejs.org/dist/](https://nodejs.org/dist/)