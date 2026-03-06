#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

HEADER="components/header.html"
FOOTER="components/footer.html"
TMP_HDR="/tmp/ethng_hdr.html"
TMP_FTR="/tmp/ethng_ftr.html"
TMP_CNT="/tmp/ethng_cnt.html"

LAST_UPDATED="March 2026"

# ──────────────────────────────────────────────
# build_page TITLE DESC CANONICAL ACTIVE_NAV CONTENT OUT BASE [JSONLD]
# BASE: "" for root, "../" for depth-1 pages
# ──────────────────────────────────────────────
build_page() {
  local TITLE="$1"
  local DESC="$2"
  local CANONICAL="$3"
  local ACTIVE_NAV="$4"
  local CONTENT="$5"
  local OUT="$6"
  local BASE="$7"
  local JSONLD="${8:-}"

  mkdir -p "$(dirname "$OUT")"

  # Header: inject active class + convert absolute paths to relative
  sed \
    -e "s|href=\"${ACTIVE_NAV}\"|href=\"${ACTIVE_NAV}\" class=\"active\"|g" \
    -e "s|href=\"/\"|href=\"${BASE}index.html\"|g" \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    "$HEADER" > "$TMP_HDR"

  # Root page: home link should be "./" not "index.html"
  if [ -z "$BASE" ]; then
    sed -i '' "s|href=\"index.html\"|href=\"./\"|g" "$TMP_HDR"
  fi

  # Footer: convert absolute paths
  sed \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    "$FOOTER" > "$TMP_FTR"

  # Content: convert absolute paths + substitute last-updated date
  sed \
    -e "s|href=\"/\([^\"]*\)\"|href=\"${BASE}\1\"|g" \
    -e "s|src=\"/\([^\"]*\)\"|src=\"${BASE}\1\"|g" \
    -e "s|{{LAST_UPDATED}}|${LAST_UPDATED}|g" \
    "$CONTENT" > "$TMP_CNT"

  # Assemble page
  {
    printf '<!DOCTYPE html>\n'
    printf '<html lang="en">\n'
    printf '<head>\n'
    printf '<meta charset="UTF-8">\n'
    printf '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
    printf '<title>%s</title>\n' "$TITLE"
    printf '<meta name="description" content="%s">\n' "$DESC"
    printf '<link rel="canonical" href="%s">\n' "$CANONICAL"
    printf '<meta property="og:type" content="article">\n'
    printf '<meta property="og:title" content="%s">\n' "$TITLE"
    printf '<meta property="og:description" content="%s">\n' "$DESC"
    printf '<meta property="og:url" content="%s">\n' "$CANONICAL"
    printf '<link rel="stylesheet" href="%scss/global.css">\n' "$BASE"
    printf '<link rel="stylesheet" href="%scss/ranking.css">\n' "$BASE"
    if [ -n "$JSONLD" ]; then
      printf '%s\n' "$JSONLD"
    fi
    printf '</head>\n'
    printf '<body>\n'
    cat "$TMP_HDR"
    printf '<main>\n'
    cat "$TMP_CNT"
    printf '</main>\n'
    cat "$TMP_FTR"
    printf '<script src="%sjs/nav.js"></script>\n' "$BASE"
    printf '</body>\n'
    printf '</html>\n'
  } > "$OUT"

  echo "Built: $OUT"
}

# ──────────────────────────────────────────────
# JSON-LD schemas for index page
# Single-quoted heredoc prevents shell variable expansion inside JSON
# ──────────────────────────────────────────────
ARTICLE_JSONLD=$(cat <<'JSONLD'
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Best Platform to Sell Ethereum in Nigeria 2026 | Ranked & Reviewed",
  "description": "Compare 7 platforms to sell Ethereum in Nigeria and receive Naira. Updated March 2026. Includes ETH/NGN exchange rates, fees, payout speed, and safety analysis.",
  "url": "https://best-platform-to-sell-ethereum-in-nigeria.com/",
  "dateModified": "2026-03-01",
  "datePublished": "2026-01-01",
  "author": {
    "@type": "Organization",
    "name": "ETH.NG Editorial Team",
    "url": "https://best-platform-to-sell-ethereum-in-nigeria.com/about/"
  },
  "publisher": {
    "@type": "Organization",
    "name": "best-platform-to-sell-ethereum-in-nigeria.com",
    "url": "https://best-platform-to-sell-ethereum-in-nigeria.com/"
  },
  "about": [
    {"@type": "Thing", "name": "Ethereum"},
    {"@type": "Thing", "name": "Nigerian Naira"},
    {"@type": "Place", "name": "Nigeria"}
  ]
}
</script>
JSONLD
)

FAQPAGE_JSONLD=$(cat <<'JSONLD'
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Which platform gives the best ETH/NGN exchange rate in Nigeria?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Instant swap platforms — particularly Platov and Breet — consistently offer competitive ETH/NGN rates for Nigerian sellers. The effective rate on these platforms typically falls within 1–2% of the mid-market rate. To find the best rate on any given day, enter the same ETH amount on Platov, Breet, and one P2P platform, and compare the total Naira you would receive."
      }
    },
    {
      "@type": "Question",
      "name": "What is the fastest way to sell Ethereum for Naira?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "The fastest method is an instant swap platform such as Platov or Breet. On Platov, Naira is delivered to your bank account as soon as the Ethereum transaction receives blockchain confirmation — typically within 5–15 minutes of sending ETH. Breet processes conversion automatically and delivers NGN within 5–30 minutes."
      }
    },
    {
      "@type": "Question",
      "name": "Is it legal to sell Ethereum in Nigeria in 2026?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Yes. Selling Ethereum in Nigeria is legal in 2026. The CBN's February 2021 directive restricted banks from directly servicing crypto exchange fiat on/off ramps, but did not make cryptocurrency ownership or trading illegal for individuals. Following the CBN's December 2023 framework for virtual asset service providers, licenced platforms can operate NGN conversion services."
      }
    },
    {
      "@type": "Question",
      "name": "P2P or instant swap — which is safer for selling ETH in Nigeria?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Instant swap platforms are generally safer for most sellers. On P2P platforms, a buyer may pay Naira from a flagged bank account, which can trigger a freeze of your receiving account. This risk does not exist on instant swap platforms like Platov and Breet, where conversion is internal and no third-party buyer ever makes a payment to your bank account."
      }
    },
    {
      "@type": "Question",
      "name": "What fees should I expect when selling ETH in Nigeria?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "There are four cost components: (1) Ethereum network gas fee ($0.50–$20); (2) platform trading fee (0% on Breet, 0.1%–2.5% on exchanges); (3) exchange rate spread (0.5%–3%); (4) NGN withdrawal fee (NGN 0 to NGN 100+ per transfer). The total effective cost is typically 1–3% for instant swap platforms."
      }
    },
    {
      "@type": "Question",
      "name": "How does the CBN regulatory environment affect my ability to sell Ethereum?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Following the CBN's February 2021 directive and its December 2023 partial reversal, Nigerian sellers can use licenced platforms to convert Ethereum to Naira and withdraw to Nigerian bank accounts. In 2026, selling ETH through licensed VASPs is legal without regulatory risk."
      }
    },
    {
      "@type": "Question",
      "name": "Do I need to complete KYC verification to sell Ethereum in Nigeria?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "KYC verification is required by all regulated platforms before you can withdraw Naira to a Nigerian bank account. Standard KYC requires a government-issued ID (NIN, BVN, international passport, or driver's licence). Breet, Luno, Busha, Paxful, and Coinbase all require KYC for NGN withdrawal."
      }
    },
    {
      "@type": "Question",
      "name": "Can I sell Ethereum directly to a Nigerian bank account without an exchange?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Not directly — the conversion step is always required. However, instant swap platforms like Platov accept Ethereum and deliver Naira directly to your bank account in a single step: send ETH, receive NGN in your bank. There is no intermediate step of withdrawing from an exchange to a bank."
      }
    }
  ]
}
</script>
JSONLD
)

ITEMLIST_JSONLD=$(cat <<'JSONLD'
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "ItemList",
  "name": "Best Platforms to Sell Ethereum in Nigeria 2026",
  "description": "Ranked list of the 7 best platforms to sell Ethereum for Nigerian Naira in 2026.",
  "url": "https://best-platform-to-sell-ethereum-in-nigeria.com/",
  "numberOfItems": 7,
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "Platov",
      "url": "https://platov.co"
    },
    {
      "@type": "ListItem",
      "position": 2,
      "name": "Breet",
      "url": "https://breet.app"
    },
    {
      "@type": "ListItem",
      "position": 3,
      "name": "Luno",
      "url": "https://luno.com"
    },
    {
      "@type": "ListItem",
      "position": 4,
      "name": "Paxful",
      "url": "https://paxful.com"
    },
    {
      "@type": "ListItem",
      "position": 5,
      "name": "Cubex",
      "url": "https://cubex.africa"
    },
    {
      "@type": "ListItem",
      "position": 6,
      "name": "Busha",
      "url": "https://busha.co"
    },
    {
      "@type": "ListItem",
      "position": 7,
      "name": "Coinbase",
      "url": "https://coinbase.com"
    }
  ]
}
</script>
JSONLD
)

COMBINED_JSONLD="${ARTICLE_JSONLD}
${FAQPAGE_JSONLD}
${ITEMLIST_JSONLD}"

# ──────────────────────────────────────────────
# Build all pages
# ──────────────────────────────────────────────

# Index page (depth 0, BASE="")
build_page \
  "Best Platform to Sell Ethereum in Nigeria 2026 | Ranked & Reviewed" \
  "Compare 7 platforms to sell Ethereum in Nigeria and receive Naira. Updated March 2026. Find the best ETH/NGN exchange rate, fastest payout, and lowest fees." \
  "https://best-platform-to-sell-ethereum-in-nigeria.com/" \
  "/" \
  "content/main-ranking.html" \
  "index.html" \
  "" \
  "$COMBINED_JSONLD"

# About (depth 1, BASE="../")
build_page \
  "About — Best Platform to Sell Ethereum in Nigeria" \
  "About the independent editorial team behind best-platform-to-sell-ethereum-in-nigeria.com. No paid placements, no affiliate links." \
  "https://best-platform-to-sell-ethereum-in-nigeria.com/about/" \
  "/about/" \
  "content/about.html" \
  "about/index.html" \
  "../"

# Editorial Policy (depth 1, BASE="../")
build_page \
  "Editorial Policy — Best Platform to Sell Ethereum in Nigeria" \
  "How we rank platforms for Nigerian ETH sellers: methodology, independence policy, and update schedule." \
  "https://best-platform-to-sell-ethereum-in-nigeria.com/editorial-policy/" \
  "/editorial-policy/" \
  "content/editorial-policy.html" \
  "editorial-policy/index.html" \
  "../"

# Contact (depth 1, BASE="../")
build_page \
  "Contact — Best Platform to Sell Ethereum in Nigeria" \
  "Contact the editorial team at best-platform-to-sell-ethereum-in-nigeria.com. Report errors, submit platforms, or send editorial enquiries." \
  "https://best-platform-to-sell-ethereum-in-nigeria.com/contact/" \
  "/contact/" \
  "content/contact.html" \
  "contact/index.html" \
  "../"

# Cookie Policy (depth 1, BASE="../")
build_page \
  "Cookie Policy — Best Platform to Sell Ethereum in Nigeria" \
  "Cookie policy for best-platform-to-sell-ethereum-in-nigeria.com. How we use cookies and your rights under applicable data protection law." \
  "https://best-platform-to-sell-ethereum-in-nigeria.com/cookie-policy/" \
  "/cookie-policy/" \
  "content/cookie-policy.html" \
  "cookie-policy/index.html" \
  "../"

# Risk Disclosure (depth 1, BASE="../")
build_page \
  "Risk Disclosure — Best Platform to Sell Ethereum in Nigeria" \
  "Risk disclosure for selling Ethereum in Nigeria: price volatility, exchange rate risk, platform counterparty risk, and regulatory risk." \
  "https://best-platform-to-sell-ethereum-in-nigeria.com/risk-disclosure/" \
  "/risk-disclosure/" \
  "content/risk-disclosure.html" \
  "risk-disclosure/index.html" \
  "../"

echo ""
echo "Build complete. All 6 pages assembled successfully."
