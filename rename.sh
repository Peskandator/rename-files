#!/bin/bash

ROOT_FOLDER="/home/pucil/skola/2026-09-29 K přejmenování"

declare -A BOOK_STARTS
declare -A BOOK_ODD

BOOK_NAMES=(
    "1946 Jihočeský kalendář"
    "1947 JČ v boji x okupantům"
    "2023 Umění neúspěchu"
    "2026 ČS-letci 1938-1945"
    "Knížky z Wisconsinu/1989 Town of Emery"
    "Knížky z Wisconsinu/1991 Phillips CS-Community"
    "Knížky z Wisconsinu/1992 Directory of the Koci family"
    "Knížky z Wisconsinu/2000 A True Life Story"
    "Knížky z Wisconsinu/2002 Stories of the Koci Family"
    "Knížky z Wisconsinu/2003 Cranberry Cookbook"
)

BOOK_STARTS=(
    ["1946 Jihočeský kalendář"]=1
    ["1947 JČ v boji x okupantům"]=3
    ["2023 Umění neúspěchu"]=1
    ["2026 ČS-letci 1938-1945"]=1
    ["Knížky z Wisconsinu/1989 Town of Emery"]=0
    ["Knížky z Wisconsinu/1991 Phillips CS-Community"]=1
    ["Knížky z Wisconsinu/1992 Directory of the Koci family"]=0
    ["Knížky z Wisconsinu/2000 A True Life Story"]=1
    ["Knížky z Wisconsinu/2002 Stories of the Koci Family"]=2
    ["Knížky z Wisconsinu/2003 Cranberry Cookbook"]=1
)

BOOK_ODD=(
    ["1946 Jihočeský kalendář"]=1
    ["1947 JČ v boji x okupantům"]=1
    ["2023 Umění neúspěchu"]=1
    ["2026 ČS-letci 1938-1945"]=1
    ["Knížky z Wisconsinu/1989 Town of Emery"]=1
    ["Knížky z Wisconsinu/1991 Phillips CS-Community"]=1
    ["Knížky z Wisconsinu/1992 Directory of the Koci family"]=1
    ["Knížky z Wisconsinu/2000 A True Life Story"]=1
    ["Knížky z Wisconsinu/2002 Stories of the Koci Family"]=1
    ["Knížky z Wisconsinu/2003 Cranberry Cookbook"]=1
)

show_help() {
    echo "Použití: ./rename.sh <číslo_knihy> [--dry-run]"
    echo ""
    echo "Dostupné knihy:"
    for i in "${!BOOK_NAMES[@]}"; do
        echo "  $((i + 1)). ${BOOK_NAMES[$i]}"
    done
    echo ""
    echo "  --dry-run  Pouze zobrazí co by se přejmenovalo"
}

if [ $# -lt 1 ]; then
    show_help
    exit 0
fi

DRY_RUN=0
BOOK_NUM=""
for arg in "$@"; do
    if [ "$arg" = "--dry-run" ]; then
        DRY_RUN=1
    else
        BOOK_NUM="$arg"
    fi
done

if [ -z "$BOOK_NUM" ]; then
    show_help
    exit 1
fi

INDEX=$((BOOK_NUM - 1))
if [ $INDEX -lt 0 ] || [ $INDEX -ge ${#BOOK_NAMES[@]} ]; then
    echo "Neplatné číslo knihy."
    exit 1
fi

BOOK_NAME="${BOOK_NAMES[$INDEX]}"
START=${BOOK_STARTS["$BOOK_NAME"]}
ODD=${BOOK_ODD["$BOOK_NAME"]}
PATH_DIR="$ROOT_FOLDER/$BOOK_NAME"

if [ ! -d "$PATH_DIR" ]; then
    echo "Složka neexistuje: $PATH_DIR"
    exit 1
fi

FIRST_FILE=""
FILE_NAMING=""
while IFS= read -r file; do
    basename_file=$(basename "$file")
    if [[ "$basename_file" != Scan_* ]] && [[ "$basename_file" != doc0* ]]; then
        FIRST_FILE="$basename_file"
        FILE_NAMING=$(echo "$basename_file" | sed -E 's/\s*[-\s]*[0-9]+\.jpg$//')
        break
    fi
done < <(find "$PATH_DIR" -maxdepth 1 -type f -name "*.jpg" | sort)

if [ -z "$FIRST_FILE" ]; then
    echo "Nenalezen vzorový soubor v '$BOOK_NAME'."
    exit 1
fi

FILES=()
while IFS= read -r file; do
    basename_file=$(basename "$file")
    FILES+=("$basename_file")
done < <(find "$PATH_DIR" -maxdepth 1 -type f -name "*.jpg" | sort)

FILE_COUNT=$((${#FILES[@]} - 1))

echo "Kniha: $BOOK_NAME"
echo "Vzor pojmenování: '$FILE_NAMING' (z '$FIRST_FILE')"
echo "Start: $START, Lichá čísla: $([ $ODD -eq 1 ] && echo 'ano' || echo 'ne')"
echo "Počet souborů k přejmenování: $FILE_COUNT"

if [ $DRY_RUN -eq 1 ]; then
    echo ""
    echo "--- DRY RUN ---"
    echo ""
fi

INCREMENT=1
if [ $ODD -eq 1 ]; then
    INCREMENT=2
fi

COUNTER=$START
RENAMED=0

for file in "${FILES[@]}"; do
    PAGE=$COUNTER
    FILENAME=$(printf "%s %03d.jpg" "$FILE_NAMING" "$PAGE")

    SOURCE="$PATH_DIR/$file"
    TARGET="$PATH_DIR/$FILENAME"

    if [ "$file" = "$FILENAME" ]; then
        echo "  [SKIP] $file (už má správný název)"
        COUNTER=$((COUNTER + INCREMENT))
        continue
    fi

    if [ $DRY_RUN -eq 1 ]; then
        echo "  $file  =>  $FILENAME"
    else
        if [ -f "$SOURCE" ]; then
            mv "$SOURCE" "$TARGET"
            echo "  [OK] $file  =>  $FILENAME"
            RENAMED=$((RENAMED + 1))
        else
            echo "  [ERR] Soubor neexistuje: $file"
        fi
    fi

    COUNTER=$((COUNTER + INCREMENT))
done

if [ $DRY_RUN -eq 1 ]; then
    echo ""
    echo "Simulace dokončena."
else
    echo ""
    echo "Přejmenováno $RENAMED souborů."
fi
