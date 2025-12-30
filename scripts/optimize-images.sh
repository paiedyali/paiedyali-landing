#!/usr/bin/env bash
set -euo pipefail

# Usage: bash scripts/optimize-images.sh
# Requirements (install via apt/homebrew):
# - pngquant
# - oxipng
# - cwebp (from libwebp)
# - imagemagick (convert)  [optional]

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS_DIR="$REPO_ROOT/dist/assets"

if [ ! -d "$ASSETS_DIR" ]; then
  echo "Erreur: $ASSETS_DIR introuvable. Assure-toi d'exécuter le script depuis la racine du repo."
  exit 1
fi

echo "Optimisation PNG / génération WebP dans : $ASSETS_DIR"

shopt -s nullglob
for f in "$ASSETS_DIR"/*.png; do
  echo "Traitement : $f"

  # 1) pngquant (lossy)
  if command -v pngquant >/dev/null 2>&1; then
    echo " - pngquant (lossy) ..."
    pngquant --quality=65-85 --speed=1 --force --output "$f" "$f" || true
  fi

  # 2) oxipng (lossless recompression)
  if command -v oxipng >/dev/null 2>&1; then
    echo " - oxipng (lossless) ..."
    oxipng -o6 --strip all "$f" || true
  fi

  # 3) generate WebP fallback (lossy)
  if command -v cwebp >/dev/null 2>&1; then
    out="${f%.png}.webp"
    echo " - cwebp -> $out"
    cwebp -q 80 "$f" -o "$out" >/dev/null 2>&1 || true
  fi

done

echo "Optimisation terminée."

echo "Conseil: Vérifie manuellement les images générées (poids, rendu) avant de committer."
