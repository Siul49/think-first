#!/usr/bin/env bash
set -euo pipefail

# think-first 설치 스크립트
# 사용법: bash scripts/install.sh /path/to/target-project --claude [--with-config]
#         bash scripts/install.sh /path/to/target-project --codex  [--with-config]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET="${1:-}"
MODE="${2:-}"
WITH_CONFIG="${3:-}"

# --- 사용법 ---
if [[ -z "$TARGET" || -z "$MODE" ]]; then
  echo "think-first 설치 스크립트"
  echo ""
  echo "사용법:"
  echo "  bash scripts/install.sh <target-path> --claude [--with-config]"
  echo "  bash scripts/install.sh <target-path> --codex  [--with-config]"
  echo "  bash scripts/install.sh <target-path> --plugin"
  echo ""
  echo "모드:"
  echo "  --claude        Claude Code용으로 설치 (.claude/skills/)"
  echo "  --codex         Codex용으로 설치 (.agent/skills/)"
  echo "  --plugin        플러그인 형식으로 설치 (.claude-plugin/ + .claude/)"
  echo ""
  echo "옵션:"
  echo "  --with-config   프로젝트 설정 파일도 함께 복사 (기존 파일 덮어쓰지 않음)"
  echo "                  --claude: CLAUDE.md"
  echo "                  --codex:  agents.md"
  echo ""
  echo "예시:"
  echo "  bash scripts/install.sh ~/Dev/my-project --claude"
  echo "  bash scripts/install.sh ~/Dev/my-project --claude --with-config"
  echo "  bash scripts/install.sh ~/Dev/my-project --codex --with-config"
  echo "  bash scripts/install.sh ~/Dev/my-project --plugin"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "[error] 대상 경로가 존재하지 않습니다: $TARGET"
  exit 1
fi

# --- 모드별 경로 설정 ---
case "$MODE" in
  --claude)
    BASE_DIR=".claude"
    SKILLS_DIR=".claude/skills"
    AGENTS_DIR=".claude/agents"
    HOOKS_DIR=".claude/hooks"
    CONTEXT_DIR=".claude/context"
    CONFIG_FILE="CLAUDE.md"
    SETTINGS_FILE=".claude/settings.json"
    IGNORE_PATTERNS=(".claude/context/" ".claude/settings.local.json")
    echo "[install] 모드: Claude Code"
    ;;
  --codex)
    BASE_DIR=".agent"
    SKILLS_DIR=".agent/skills"
    AGENTS_DIR=".agent/agents"
    HOOKS_DIR=".agent/hooks"
    CONTEXT_DIR=".agent/context"
    CONFIG_FILE="agents.md"
    SETTINGS_FILE=".agent/settings.json"
    IGNORE_PATTERNS=(".agent/context/")
    echo "[install] 모드: Codex"
    ;;
  --plugin)
    BASE_DIR=".claude"
    SKILLS_DIR=".claude/skills"
    AGENTS_DIR=".claude/agents"
    HOOKS_DIR=".claude/hooks"
    CONTEXT_DIR=".claude/context"
    CONFIG_FILE="CLAUDE.md"
    SETTINGS_FILE=".claude/settings.json"
    PLUGIN_DIR=".claude-plugin"
    IGNORE_PATTERNS=(".claude/context/" ".claude/settings.local.json")
    echo "[install] 모드: Plugin"
    ;;
  *)
    echo "[error] 알 수 없는 모드: $MODE (--claude, --codex 또는 --plugin을 사용하세요)"
    exit 1
    ;;
esac

# --- 1. 스킬 복사 ---
echo "[install] 스킬 복사 중..."
mkdir -p "$TARGET/$SKILLS_DIR"
cp -r "$PACK_ROOT/.claude/skills/"* "$TARGET/$SKILLS_DIR/"
SKILL_COUNT=$(find "$TARGET/$SKILLS_DIR" -name 'SKILL.md' | wc -l | tr -d ' ')
echo "[install] $SKILLS_DIR/ → 완료 (${SKILL_COUNT}개 스킬)"

# --- 2. 한국어 스타일 가이드 복사 ---
if [[ -f "$PACK_ROOT/.claude/korean-docs-style-guide.md" ]]; then
  GUIDE_DIR=$(dirname "$TARGET/$SKILLS_DIR")
  cp "$PACK_ROOT/.claude/korean-docs-style-guide.md" "$GUIDE_DIR/"
  echo "[install] korean-docs-style-guide.md → 완료"
fi

# --- 3. 프로젝트 설정 파일 (선택) ---
if [[ "$WITH_CONFIG" == "--with-config" ]]; then
  if [[ "$MODE" == "--claude" ]]; then
    # Claude Code: CLAUDE.md 복사
    if [[ -f "$TARGET/CLAUDE.md" ]]; then
      echo "[install] CLAUDE.md가 이미 존재합니다. 덮어쓰지 않습니다."
      cp "$PACK_ROOT/CLAUDE.md" "$TARGET/CLAUDE.md.think-first-template"
      echo "[install] 템플릿을 CLAUDE.md.think-first-template로 저장합니다."
    else
      cp "$PACK_ROOT/CLAUDE.md" "$TARGET/CLAUDE.md"
      echo "[install] CLAUDE.md → 완료 (프로젝트에 맞게 수정하세요)"
    fi
  else
    # Codex: agents.md 복사 (CLAUDE.md를 agents.md로 변환)
    if [[ -f "$TARGET/agents.md" ]]; then
      echo "[install] agents.md가 이미 존재합니다. 덮어쓰지 않습니다."
      cp "$PACK_ROOT/CLAUDE.md" "$TARGET/agents.md.think-first-template"
      echo "[install] 템플릿을 agents.md.think-first-template로 저장합니다."
    else
      # CLAUDE.md 내용에서 경로만 치환하여 agents.md로 저장
      sed 's|\.claude/skills/|.agent/skills/|g; s|\.claude/context/|.agent/context/|g' \
        "$PACK_ROOT/CLAUDE.md" > "$TARGET/agents.md"
      echo "[install] agents.md → 완료 (프로젝트에 맞게 수정하세요)"
    fi
  fi
fi

# --- 4. 서브에이전트 복사 ---
if [[ -d "$PACK_ROOT/.claude/agents" ]]; then
  echo "[install] 서브에이전트 복사 중..."
  mkdir -p "$TARGET/$AGENTS_DIR"
  cp -r "$PACK_ROOT/.claude/agents/"* "$TARGET/$AGENTS_DIR/"
  AGENT_COUNT=$(find "$TARGET/$AGENTS_DIR" -name '*.md' | wc -l | tr -d ' ')
  echo "[install] $AGENTS_DIR/ → 완료 (${AGENT_COUNT}개 에이전트)"
fi

# --- 5. Hooks 복사 ---
if [[ -d "$PACK_ROOT/.claude/hooks" ]]; then
  echo "[install] Hook 스크립트 복사 중..."
  mkdir -p "$TARGET/$HOOKS_DIR"
  cp -r "$PACK_ROOT/.claude/hooks/"* "$TARGET/$HOOKS_DIR/"
  chmod +x "$TARGET/$HOOKS_DIR/"*.sh 2>/dev/null || true
  echo "[install] $HOOKS_DIR/ → 완료"
fi

# --- 6. settings.json 복사 (hooks 설정, 덮어쓰기 방지) ---
if [[ -f "$PACK_ROOT/.claude/settings.json" ]]; then
  if [[ -f "$TARGET/$SETTINGS_FILE" ]]; then
    echo "[install] $SETTINGS_FILE 이미 존재합니다. 덮어쓰지 않습니다."
    if [[ "$MODE" == "--codex" ]]; then
      sed 's|\.claude/hooks/|.agent/hooks/|g; s|\.claude/context/|.agent/context/|g' \
        "$PACK_ROOT/.claude/settings.json" > "$TARGET/${SETTINGS_FILE}.think-first-template"
    else
      cp "$PACK_ROOT/.claude/settings.json" "$TARGET/${SETTINGS_FILE}.think-first-template"
    fi
    echo "[install] 템플릿을 ${SETTINGS_FILE}.think-first-template로 저장합니다."
  else
    if [[ "$MODE" == "--codex" ]]; then
      sed 's|\.claude/hooks/|.agent/hooks/|g; s|\.claude/context/|.agent/context/|g' \
        "$PACK_ROOT/.claude/settings.json" > "$TARGET/$SETTINGS_FILE"
    else
      cp "$PACK_ROOT/.claude/settings.json" "$TARGET/$SETTINGS_FILE"
    fi
    echo "[install] $SETTINGS_FILE → 완료 (hooks 설정 포함)"
  fi
fi

# --- 7. context 디렉토리 초기화 ---
mkdir -p "$TARGET/$CONTEXT_DIR"
echo "[install] $CONTEXT_DIR/ → 초기화 완료"

# --- 7.5. reflections 디렉토리 초기화 ---
REFLECTIONS_DIR="$(dirname "$CONTEXT_DIR")/reflections"
mkdir -p "$TARGET/$REFLECTIONS_DIR"
touch "$TARGET/$REFLECTIONS_DIR/.gitkeep"
echo "[install] $REFLECTIONS_DIR/ → 초기화 완료 (회고 기록용)"

# --- 8. .gitignore 업데이트 ---
if [[ -f "$TARGET/.gitignore" ]]; then
  NEEDS_UPDATE=false
  for pattern in "${IGNORE_PATTERNS[@]}"; do
    if ! grep -q "$pattern" "$TARGET/.gitignore" 2>/dev/null; then
      NEEDS_UPDATE=true
      break
    fi
  done

  if [[ "$NEEDS_UPDATE" == "true" ]]; then
    echo "" >> "$TARGET/.gitignore"
    echo "# think-first runtime" >> "$TARGET/.gitignore"
    for pattern in "${IGNORE_PATTERNS[@]}"; do
      if ! grep -q "$pattern" "$TARGET/.gitignore" 2>/dev/null; then
        echo "$pattern" >> "$TARGET/.gitignore"
      fi
    done
    echo "[install] .gitignore 업데이트 → 완료"
  fi
fi

# --- 8.5. 플러그인 메타데이터 복사 (--plugin 모드) ---
if [[ "$MODE" == "--plugin" && -d "$PACK_ROOT/.claude-plugin" ]]; then
  echo "[install] 플러그인 메타데이터 복사 중..."
  mkdir -p "$TARGET/$PLUGIN_DIR"
  cp "$PACK_ROOT/.claude-plugin/plugin.json" "$TARGET/$PLUGIN_DIR/"
  echo "[install] $PLUGIN_DIR/plugin.json → 완료"
fi

# --- 완료 ---
echo ""
echo "[install] 설치 완료! ($MODE)"
echo ""
echo "다음 단계:"
echo "  1. $CONFIG_FILE을 프로젝트에 맞게 수정하세요"
echo "     - '사용자 환경' 섹션의 호칭, 문체 등"
echo "     - '커밋 규칙'의 Co-Authored-By"
echo "     - 프로젝트에 불필요한 스킬이 있으면 해당 디렉토리 삭제"
echo "  2. manage-skills 스킬로 프로젝트별 verify 스킬을 생성하세요"
echo "  3. 복합 작업 시 $CONTEXT_DIR/에 계획서가 자동 생성됩니다"
