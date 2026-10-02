# Přejmenování naskenovaných knížek

Skript pro hromadné přejmenování naskenovaných stránek knížek ze scanneru (Scan_*.jpg) na srozumitelný formát.

## Spuštění (Bash)

```bash
# Zobrazit seznam knih
./rename.sh

# Dry run (simulace) - zobrazí co by se přejmenovalo
./rename.sh 1 --dry-run

# Přejmenovat soubory
./rename.sh 1
```

## Spuštění (PHP přes Docker)

```bash
# Sestavit image
docker build -t rename-files .

# Zobrazit seznam knih (složka s knížkami se připojí jako volume)
docker run --rm -v "/cesta/ke/složce:/data" rename-files

# Dry run
docker run --rm -v "/cesta/ke/složce:/data" rename-files 1 --dry-run

# Přejmenovat soubory
docker run --rm -v "/cesta/ke/složce:/data" rename-files 1
```

## Jak to funguje

1. V každé složce s knížkou je první soubor už správně pojmenovaný (např. `1946 Jihočeský kalendář 001.jpg`)
2. Skript z něj odvodí vzor pojmenování
3. Ostatní soubory (Scan_*.jpg) přejmenuje sekvenčně podle tohoto vzoru
4. Složka `Nechat být` se přeskakuje
5. Číslování je ve výchozím stavu lichými čísly (1, 3, 5, ...) - každý sken = dvoustrana
