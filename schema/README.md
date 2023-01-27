# Asserest configuration file schema files

This directory contains [JSON schema](asserest_schema.json) for editing YAML asserest configuration file.
It also contains [example](example.yaml) for referencing an example of setup script.

# Binding schema with IDE

It may differ depending on which IDE or extension you uses, it only shows the most ideal way of configuration.

## Visual Studio Code

### Prerequisite

* [YAML extension](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) by RedHat has been installed and enabled

### Setup

Editing `settings.json` under `.vscode` in opened workspace directory (**DO NOT** apply to global setting directly):

```json
{
    "yaml.schemas": {
        "(URI address of asserest_schema.json)": "/path/to/config/file.yaml"
    }
}
```



