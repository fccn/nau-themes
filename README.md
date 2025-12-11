# NAU Themes for Open edX

This repository contains the NAU themes for Open edX platform and ecommerce.

## Project Structure

```
nau-themes/
├── Makefile                 # Master orchestrator for shared infrastructure
├── requirements.txt         # Shared Python dependencies
├── edx-platform/
│   ├── Makefile            # EdX Platform theme translations (pybabel)
│   └── nau-basic/          # NAU theme for LMS/CMS
└── ecommerce/
    ├── Makefile            # Ecommerce theme translations (Django)
    └── nau/                # NAU theme for ecommerce
```

## Requirements

- **Python 3.11+** (enforced by the Makefile)
- gettext package

## Quick Start

### 1. Create Virtual Environment

The root Makefile manages a shared virtual environment for all themes:

```bash
# Create venv with Python 3.11+ check and install dependencies
make venv
```

### 2. Update Translations

**Run translations for all themes:**
```bash
make translations
```

## Working with Individual Themes

Each subdirectory has its own Makefile for component-specific operations:

### EdX Platform Theme

```bash
cd edx-platform
make help              # Show available targets
make translations      # Full translation workflow
make translations_extract
make translations_compile
```

### Ecommerce Theme

```bash
cd ecommerce
make help              # Show available targets
make translations      # Full translation workflow
make translations_extract
make translations_compile
```

## Available Make Targets

### Root Makefile (Orchestrator)

**Shared Infrastructure:**
- `make venv` - Create virtual environment with Python 3.11+
- `make check-python` - Verify Python version
- `make requirements` - Update installed requirements
- `make clean` - Remove virtual environment

**Translation Orchestration:**
- `make translations` - Run all theme translations
- `make translations-all` - Same as above
- `make translations-edx` - EdX Platform translations only
- `make translations-ecommerce` - Ecommerce translations only
- `make translations-extract-all` - Extract from all themes
- `make translations-compile-all` - Compile all themes

Run `make help` for complete list with descriptions.

## Development Workflow

1. **First time setup:**
   ```bash
   make venv
   ```

2. **After modifying templates:**
   ```bash
   make translations-edx        # If you changed EdX Platform templates
   make translations-ecommerce  # If you changed ecommerce templates
   make translations-all        # If you changed both
   ```

3. **Update dependencies:**
   ```bash
   make requirements
   ```

## Technical Details

### Translation Tools

- **EdX Platform** (`edx-platform/`): Uses `pybabel` for Mako and Underscore templates
- **Ecommerce** (`ecommerce/`): Uses Django's `makemessages` for Django templates

### Supported Languages

- English (`en`)
- Portuguese (`pt_PT`)

## Troubleshooting

**Error: Python 3.11+ required**
- Ensure `python` command points to Python 3.11+
- Use `pyenv` or `uv` (`uv venv --seed venv -p python3.11`) or update your PATH

**Error: Virtual environment not found**
- Run `make venv` from the project root first
