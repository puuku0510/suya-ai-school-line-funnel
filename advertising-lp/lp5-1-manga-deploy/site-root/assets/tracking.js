(function () {
  "use strict";

  const config = window.AI_SEMINAR_TRACKING || {};
  const lpId = location.pathname.split("/").filter(Boolean)[0] || "unknown";
  const allowedParam = /^(utm_(source|medium|campaign|content|term|id)|fbclid|gclid|lp_id|cr_id)$/;

  function isPublicHttpUrl(value) {
    try {
      const url = new URL(value);
      return /^https?:$/.test(url.protocol) && !/PENDING/i.test(value);
    } catch (_) {
      return false;
    }
  }

  function buildUtageUrl(base) {
    const target = new URL(base);
    const current = new URLSearchParams(location.search);
    current.forEach((value, key) => {
      if (allowedParam.test(key)) target.searchParams.set(key, value);
    });
    if (!target.searchParams.has("lp_id")) target.searchParams.set("lp_id", lpId);
    return target.toString();
  }

  const utageBase = config.utageByLp && config.utageByLp[lpId];
  const ctas = document.querySelectorAll('a[href="#line-link-pending"]');

  if (isPublicHttpUrl(utageBase)) {
    const destination = buildUtageUrl(utageBase);
    ctas.forEach((cta) => {
      cta.href = destination;
      cta.dataset.lpId = lpId;
    });
  } else {
    ctas.forEach((cta) => {
      cta.dataset.trackingPending = "true";
      cta.setAttribute("aria-disabled", "true");
      cta.addEventListener("click", (event) => event.preventDefault());
    });
    console.error("[AI seminar LP] UTAGE URL is not configured for", lpId);
  }

  const pixelId = String(config.metaPixelId || "");
  if (/^\d{10,20}$/.test(pixelId)) {
    if (!window.fbq) {
      (function (f, b, e, v, n, t, s) {
        if (f.fbq) return;
        n = f.fbq = function () {
          n.callMethod ? n.callMethod.apply(n, arguments) : n.queue.push(arguments);
        };
        if (!f._fbq) f._fbq = n;
        n.push = n;
        n.loaded = true;
        n.version = "2.0";
        n.queue = [];
        t = b.createElement(e);
        t.async = true;
        t.src = v;
        s = b.getElementsByTagName(e)[0];
        s.parentNode.insertBefore(t, s);
      })(window, document, "script", "https://connect.facebook.net/en_US/fbevents.js");
    }
    window.fbq("init", pixelId);
    window.fbq("track", "PageView", { lp_id: lpId });
  } else {
    console.error("[AI seminar LP] Meta Pixel ID is not configured");
  }

  window.__AI_SEMINAR_TRACKING_READY__ = {
    lpId,
    ctaCount: ctas.length,
    utageConfigured: isPublicHttpUrl(utageBase),
    pixelConfigured: /^\d{10,20}$/.test(pixelId)
  };
})();
