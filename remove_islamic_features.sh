#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./remove_islamic_features.sh [BRANCH_NAME] [BASE_BRANCH]
BRANCH="${1:-remove-islamic-features}"
BASE="${2:-main}"
ARCHIVE_DIR="archive_removed_features_$(date +%Y%m%d%H%M%S)"
COMMIT_MSG="chore: remove audio, hadith library, radio, qibla, asma, adhkar, notifications, tasbih, hijri features"
PR_BODY="طلب حذف الميزات: صوتيات، مكتبة الحديث، الراديو، القبلة، أسماء الله الحسنى، الأذكار والأدعية، الاشعارات، السبحة، التقويم الهجري.\n\nتم أرشفة الملفات/المجلدات ذات الصلة إلى $ARCHIVE_DIR."

# Safety: require clean working tree
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "خطأ: هناك تغييرات محلية غير مرتكَبة. الرجاء عمل commit أو stash ثم أعد المحاولة."
  exit 1
fi

git fetch origin
if git rev-parse --verify "origin/$BASE" >/dev/null 2>&1; then
  git checkout -b "$BRANCH" "origin/$BASE"
else
  git checkout -b "$BRANCH" "$BASE"
fi

mkdir -p "$ARCHIVE_DIR"

KEYWORDS=(
  "صوتيات" "مكتبة الحديث" "الحديث"
  "الراديو" "radio"
  "القبلة" "القبله" "qibla" "qiblah"
  "أسماء الله" "اسماء الله" "asma" "asmaa" "asmaul"
  "الأذكار" "اذكار" "adhkar" "azkar"
  "الأدعية" "ادعية" "duas" "duaa" "dua"
  "الاشعارات" "اشعارات" "notifications" "push" "fcm"
  "السبحة" "سبحة" "tasbih" "tasbeeh"
  "التقويم الهجري" "هجري" "hijri" "hijri_calendar"
)

DIR_NAMES=(
  "audio" "audios" "player" "hadith" "hadiths" "radio" "qibla" "qiblah"
  "asma" "asmaa" "asmaul" "adhkar" "azkar" "tasbih" "tasbeeh" "hijri" "hijri_calendar"
  "notifications" "notification" "push" "fcm"
)

echo "> البحث عن ملفات تحتوي على كلمات المفتاح ونقلها إلى $ARCHIVE_DIR ..."
for kw in "${KEYWORDS[@]}"; do
  mapfile -t files < <(grep -RIl --exclude-dir=.git -e "$kw" . || true)
  for f in "${files[@]}"; do
    if [[ "$f" == "./$ARCHIVE_DIR"* || "$f" == "$ARCHIVE_DIR"* ]]; then continue; fi
    dest="$ARCHIVE_DIR/$(dirname "$f")"
    mkdir -p "$dest"
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      git mv "$f" "$dest/" || mv -f "$f" "$dest/"
    else
      mv -f "$f" "$dest/" || true
    fi
    echo "  moved $f -> $dest/"
  done
done

echo ">> البحث عن مجلدات بأسماء معروفة ونقلها ..."
for dname in "${DIR_NAMES[@]}"; do
  mapfile -t dirs < <(find . -type d -iname "$dname" -not -path "./.git/*" -not -path "./$ARCHIVE_DIR/*" || true)
  for d in "${dirs[@]}"; do
    if [[ "$d" == "." ]]; then continue; fi
    dest="$ARCHIVE_DIR/$(dirname "$d")"
    mkdir -p "$dest"
    if [ -d "$d" ]; then
      git mv "$d" "$dest/" 2>/dev/null || mv -f "$d" "$dest/"
      echo "  moved dir $d -> $dest/"
    fi
  done
done

ASSET_DIRS=("assets/audio" "assets/audios" "assets/hadith" "assets/radio" "assets/asma" "assets/tasbih" "assets/hijri")
for ad in "${ASSET_DIRS[@]}"; do
  if [ -d "$ad" ]; then
    dest="$ARCHIVE_DIR/$ad"
    mkdir -p "$(dirname "$dest")"
    git mv "$ad" "$dest" 2>/dev/null || mv -f "$ad" "$dest"
    echo "  moved asset dir $ad -> $dest"
  fi
done

echo ">>> طباعة نتائج البحث لوجود مراجع يدوية (راجعها يدوياً):"
for kw in "${KEYWORDS[@]}"; do
  grep -RIn --exclude-dir=.git -e "$kw" . || true
done | sed -n '1,300p'

# try flutter analyze/fix (best-effort)
if command -v flutter >/dev/null 2>&1; then
  flutter pub get || true
  flutter analyze || true
  if command -v dart >/dev/null 2>&1; then
    dart fix --apply || true
  fi
fi

git add -A
git commit -m "$COMMIT_MSG" || true
git push -u origin "$BRANCH"
echo "انتهى: الأرشيف موجود في: $ARCHIVE_DIR"
