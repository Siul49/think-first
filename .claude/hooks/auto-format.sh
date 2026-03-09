#!/usr/bin/env bash
# PostToolUse(Edit|Write) hook: 파일 수정 후 프로젝트 포매터 자동 실행
# 포매터 미설치 시 무시 (exit 0)

set -euo pipefail

INPUT=$(cat)

# 파일 경로 추출 (jq 우선, grep fallback)
if command -v jq &>/dev/null; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null || echo "")
else
  FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | sed 's/"file_path":"//;s/"$//' 2>/dev/null || echo "")
  if [[ -z "$FILE_PATH" ]]; then
    FILE_PATH=$(echo "$INPUT" | grep -o '"filePath":"[^"]*"' | head -1 | sed 's/"filePath":"//;s/"$//' 2>/dev/null || echo "")
  fi
fi

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# 확장자 추출
EXT="${FILE_PATH##*.}"

# 포매터 감지 및 실행 (10초 타임아웃)
format_file() {
  local file="$1"
  local ext="$2"

  case "$ext" in
    js|jsx|ts|tsx|css|scss|json|html|vue|svelte|md|yaml|yml)
      # Prettier
      if [[ -f "node_modules/.bin/prettier" ]]; then
        timeout 10 node_modules/.bin/prettier --write "$file" 2>/dev/null && return 0
      elif command -v npx &>/dev/null && [[ -f ".prettierrc" || -f ".prettierrc.json" || -f ".prettierrc.js" || -f ".prettierrc.yaml" || -f "prettier.config.js" || -f "prettier.config.mjs" ]]; then
        timeout 10 npx prettier --write "$file" 2>/dev/null && return 0
      fi
      # Biome
      if [[ -f "node_modules/.bin/biome" ]]; then
        timeout 10 node_modules/.bin/biome format --write "$file" 2>/dev/null && return 0
      fi
      ;;
    py)
      # Ruff (fastest)
      if command -v ruff &>/dev/null; then
        timeout 10 ruff format "$file" 2>/dev/null && return 0
      fi
      # Black
      if command -v black &>/dev/null; then
        timeout 10 black --quiet "$file" 2>/dev/null && return 0
      fi
      ;;
    go)
      if command -v gofmt &>/dev/null; then
        timeout 10 gofmt -w "$file" 2>/dev/null && return 0
      fi
      ;;
    rs)
      if command -v rustfmt &>/dev/null; then
        timeout 10 rustfmt "$file" 2>/dev/null && return 0
      fi
      ;;
    c|cpp|h|hpp|cc)
      if command -v clang-format &>/dev/null && [[ -f ".clang-format" ]]; then
        timeout 10 clang-format -i "$file" 2>/dev/null && return 0
      fi
      ;;
    dart)
      if command -v dart &>/dev/null; then
        timeout 10 dart format "$file" 2>/dev/null && return 0
      fi
      ;;
    swift)
      if command -v swift-format &>/dev/null; then
        timeout 10 swift-format --in-place "$file" 2>/dev/null && return 0
      fi
      ;;
    kt|kts)
      if command -v ktfmt &>/dev/null; then
        timeout 10 ktfmt "$file" 2>/dev/null && return 0
      fi
      ;;
  esac

  return 1
}

if format_file "$FILE_PATH" "$EXT" 2>/dev/null; then
  echo "자동 포매팅 완료: $FILE_PATH" >&2
fi

exit 0
