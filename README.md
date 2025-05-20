# NAU Themes for OpenEdx

This repository contains the NAU themes.

The Makefile on project root extracts on edx-platform. The Makefile on ecommerce folder extracts for the ecommerce.

## Python
This repository requires the Python version 3.11.

## Create a virtual environment

```bash
pyenv shell 3.11
python --version
python -m venv venv
. venv/bin/activate
```

## Requirements

```bash
make requirements
```

## Update translations

To extract the strings to be translated, add them to .po files and to compile the translation .mo
files, run the Makefile target `translations`.

```bash
make translations
```
