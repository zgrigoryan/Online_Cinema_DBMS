#!/usr/bin/env bash
set -euo pipefail

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BASEDIR/frontend"

npm install
npm run dev -- --host 0.0.0.0 --port 5173
