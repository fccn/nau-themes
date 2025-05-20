NAU Themes for Ecommerce
=============================

This directory contains a NAU theme for the Open edX Ecommerce.

The full documentation about theming the Open edX Ecommerce can be found directly on Ecommerce
repository, link:
https://github.com/openedx/ecommerce/blob/open-release/nutmeg.master/docs/theming.rst

This file contains further instructions or specific information related to NAU theme.

## Settings
To configure nau theme you need to do this configuration.

Configure the settings: 
- `ENABLE_COMPREHENSIVE_THEMING`
- `COMPREHENSIVE_THEME_DIRS`
- `DEFAULT_SITE_THEME`

Example:
```python
ENABLE_COMPREHENSIVE_THEMING = True
COMPREHENSIVE_THEME_DIRS = ['/edx/app/edx-themes/ecommerce/']
DEFAULT_SITE_THEME = 'nau'
```

## Compiling Theme Sass
To build the NAU theme on ecommerce, you need to run this command inside the `ecommerce` container.

```bash
python manage.py update_assets --themes nau
```
