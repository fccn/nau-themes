/**
 * NAU: detect and recover from Studio AJAX calls failing due to an expired session.
 *
 * Background: Studio's legacy (non-MFE) pages have no handling at all for a session
 * expiring mid-edit. When that happens, the next AJAX call (e.g. clicking "Save") gets
 * redirected through the LMS OAuth2 SSO flow instead of returning its expected response.
 * Browsers block following that cross-origin redirect chain for XHR/fetch requests (CORS),
 * so the request fails with a generic, unrecoverable network error - "Unable to save",
 * with no explanation and no way to recover without manually reloading the page.
 *
 * This file does not fix the underlying session expiration; it only makes the failure
 * visible and recoverable, by watching for the network-error signature that a blocked
 * cross-origin redirect produces on same-origin AJAX calls, and prompting the user to
 * reload (preserving a chance to re-authenticate) instead of silently failing.
 *
 * Deliberately dependency-free (no jQuery/Backbone): this script is loaded in <head>,
 * before Studio's other scripts, so it cannot assume anything else has loaded yet.
 */
(function() {
  'use strict';

  var bannerShown = false;

  // jsi18n_path is loaded earlier in base.html, so window.gettext should already
  // be defined by the time this script runs; fall back to English if not.
  function translate(text) {
    return (typeof window.gettext === 'function') ? window.gettext(text) : text;
  }

  function isSameOriginUrl(url) {
    try {
      var resolved = new URL(url, window.location.href);
      return resolved.origin === window.location.origin;
    } catch (e) {
      return false;
    }
  }

  function showSessionExpiredBanner() {
    if (bannerShown) {
      return;
    }
    bannerShown = true;

    var banner = document.createElement('div');
    banner.setAttribute('role', 'alert');
    banner.style.cssText = [
      'position:fixed', 'top:0', 'left:0', 'right:0', 'z-index:2147483647',
      'background:#b20610', 'color:#fff', 'font-family:sans-serif', 'font-size:14px',
      'padding:12px 16px', 'display:flex', 'align-items:center', 'justify-content:center',
      'gap:16px', 'box-shadow:0 2px 6px rgba(0,0,0,0.3)'
    ].join(';');

    var message = document.createElement('span');
    message.textContent = translate(
      'Your session appears to have expired, so this action was not saved. ' +
      'Please reload the page and log in again before continuing.'
    );

    var reloadButton = document.createElement('button');
    reloadButton.type = 'button';
    reloadButton.textContent = translate('Reload page');
    reloadButton.style.cssText = [
      'background:#fff', 'color:#b20610', 'border:none', 'border-radius:3px',
      'padding:6px 14px', 'font-weight:bold', 'cursor:pointer', 'flex-shrink:0'
    ].join(';');
    reloadButton.onclick = function() {
      window.location.reload();
    };

    var dismissButton = document.createElement('button');
    dismissButton.type = 'button';
    dismissButton.textContent = translate('Dismiss');
    dismissButton.setAttribute('aria-label', translate('Dismiss'));
    dismissButton.style.cssText = [
      'background:transparent', 'color:#fff', 'border:1px solid #fff', 'border-radius:3px',
      'padding:6px 14px', 'cursor:pointer', 'flex-shrink:0'
    ].join(';');
    dismissButton.onclick = function() {
      banner.remove();
      bannerShown = false;
    };

    banner.appendChild(message);
    banner.appendChild(reloadButton);
    banner.appendChild(dismissButton);
    document.body.appendChild(banner);
  }

  function looksLikeBlockedAuthRedirect(url, status) {
    // status 0 with no response is the browser's network-error signature for a
    // same-origin request whose cross-origin redirect target (the LMS OAuth2 flow)
    // was blocked by CORS. Genuine offline/DNS failures produce the same signature,
    // but in that case reloading is also the right recovery action, so we don't need
    // to distinguish between the two cases here.
    return status === 0 && isSameOriginUrl(url);
  }

  // --- XMLHttpRequest ---
  var originalOpen = XMLHttpRequest.prototype.open;
  var originalSend = XMLHttpRequest.prototype.send;

  XMLHttpRequest.prototype.open = function(method, url) {
    this._nauRequestUrl = url;
    return originalOpen.apply(this, arguments);
  };

  XMLHttpRequest.prototype.send = function() {
    this.addEventListener('loadend', function() {
      if (looksLikeBlockedAuthRedirect(this._nauRequestUrl, this.status)) {
        showSessionExpiredBanner();
      }
    });
    return originalSend.apply(this, arguments);
  };

  // --- fetch (not currently used by Studio's legacy pages, kept for completeness) ---
  if (window.fetch) {
    var originalFetch = window.fetch;
    window.fetch = function(input, init) {
      var url = typeof input === 'string' ? input : input && input.url;
      return originalFetch.apply(this, arguments).catch(function(error) {
        if (url && isSameOriginUrl(url)) {
          showSessionExpiredBanner();
        }
        throw error;
      });
    };
  }
})();
