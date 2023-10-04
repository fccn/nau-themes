# NAU Ecommerce theme

## Configuration
To configure the Open edX Devstack add this settings on the file `ecommerce/settings/private.py`.

```python
ENABLE_COMPREHENSIVE_THEMING = True
COMPREHENSIVE_THEME_DIRS = ['/edx/app/edx-themes/ecommerce/']
DEFAULT_SITE_THEME = 'nau'
```

## Build theme
To build the nau theme of ecommerce, run this command inside the `ecommerce` container.

```bash
python manage.py update_assets --themes nau
```

## Theming problem on Devstack

Error:
```
RecursionError: maximum recursion depth exceeded while calling a Python object
```

Stacktrace:
```
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/loaders/base.py", line 18, in get_template
edx.devstack-nau-nutmeg.master.ecommerce |     for origin in self.get_template_sources(template_name):
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/loaders/filesystem.py", line 34, in get_template_sources
edx.devstack-nau-nutmeg.master.ecommerce |     for template_dir in self.get_dirs():
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/ecommerce/ecommerce/theming/template_loaders.py", line 23, in get_dirs
edx.devstack-nau-nutmeg.master.ecommerce |     theme = get_current_theme()
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/ecommerce/ecommerce/theming/helpers.py", line 42, in get_current_theme
edx.devstack-nau-nutmeg.master.ecommerce |     if not is_comprehensive_theming_enabled():
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/ecommerce/ecommerce/theming/helpers.py", line 101, in is_comprehensive_theming_enabled
edx.devstack-nau-nutmeg.master.ecommerce |     if bool(get_current_request()) and waffle.switch_is_active(settings.DISABLE_THEMING_ON_RUNTIME_SWITCH):
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/waffle/__init__.py", line 22, in switch_is_active
edx.devstack-nau-nutmeg.master.ecommerce |     switch = Switch.get(switch_name)
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/waffle/models.py", line 39, in get
edx.devstack-nau-nutmeg.master.ecommerce |     cached = cache.get(cache_key)
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/debug_toolbar/panels/cache.py", line 49, in wrapped
edx.devstack-nau-nutmeg.master.ecommerce |     cache_called.send(
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/dispatch/dispatcher.py", line 180, in send
edx.devstack-nau-nutmeg.master.ecommerce |     return [
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/dispatch/dispatcher.py", line 181, in <listcomp>
edx.devstack-nau-nutmeg.master.ecommerce |     (receiver, receiver(signal=self, sender=sender, **named))
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/debug_toolbar/panels/cache.py", line 236, in _store_call_info
edx.devstack-nau-nutmeg.master.ecommerce |     "trace": render_stacktrace(trace),
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/debug_toolbar/utils.py", line 84, in render_stacktrace
edx.devstack-nau-nutmeg.master.ecommerce |     render_to_string(
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/loader.py", line 61, in render_to_string
edx.devstack-nau-nutmeg.master.ecommerce |     template = get_template(template_name, using=using)
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/loader.py", line 15, in get_template
edx.devstack-nau-nutmeg.master.ecommerce |     return engine.get_template(template_name)
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/backends/django.py", line 34, in get_template
edx.devstack-nau-nutmeg.master.ecommerce |     return Template(self.engine.get_template(template_name), self)
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/engine.py", line 143, in get_template
edx.devstack-nau-nutmeg.master.ecommerce |     template, origin = self.find_template(template_name)
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/engine.py", line 125, in find_template
edx.devstack-nau-nutmeg.master.ecommerce |     template = loader.get_template(name, skip=skip)
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/loaders/base.py", line 18, in get_template
edx.devstack-nau-nutmeg.master.ecommerce |     for origin in self.get_template_sources(template_name):
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/django/template/loaders/filesystem.py", line 34, in get_template_sources
edx.devstack-nau-nutmeg.master.ecommerce |     for template_dir in self.get_dirs():
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/ecommerce/ecommerce/theming/template_loaders.py", line 23, in get_dirs
edx.devstack-nau-nutmeg.master.ecommerce |     theme = get_current_theme()
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/ecommerce/ecommerce/theming/helpers.py", line 42, in get_current_theme
edx.devstack-nau-nutmeg.master.ecommerce |     if not is_comprehensive_theming_enabled():
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/ecommerce/ecommerce/theming/helpers.py", line 101, in is_comprehensive_theming_enabled
edx.devstack-nau-nutmeg.master.ecommerce |     if bool(get_current_request()) and waffle.switch_is_active(settings.DISABLE_THEMING_ON_RUNTIME_SWITCH):
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/threadlocals/threadlocals.py", line 27, in get_current_request
edx.devstack-nau-nutmeg.master.ecommerce |     return get_thread_variable('request', None)
edx.devstack-nau-nutmeg.master.ecommerce |   File "/edx/app/ecommerce/venvs/ecommerce/lib/python3.8/site-packages/threadlocals/threadlocals.py", line 23, in get_thread_variable
edx.devstack-nau-nutmeg.master.ecommerce |     return getattr(_threadlocals, key, default)
edx.devstack-nau-nutmeg.master.ecommerce | RecursionError: maximum recursion depth exceeded while calling a Python object

```

File:
```
ecommerce/theming/helpers.py
```

Comment the lines:
```python
    # if bool(get_current_request()) and waffle.switch_is_active(settings.DISABLE_THEMING_ON_RUNTIME_SWITCH):
    #     return False
```
