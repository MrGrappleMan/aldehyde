
# Build-time scripts
Allow you to easily make changes to the image that will be produced during the building process. They are listed in their order of execution, first from the top.
| Script name | Purpose |
| --- | --- |
| dnf5.fish | Installs packages to the immutable layer with DNF5 |
| systemd.fish | Makes Systemd consider the correct service files to run from |


