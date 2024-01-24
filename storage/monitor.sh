#!/bin/bash
# Percorsi delle cartelle
dlfolder="/srv/homes/pvc-b446e9d5-a1db-4b2d-8de1-dc9bb21ea984"
extractionfolder="/srv/homes/pvc-b446e9d5-a1db-4b2d-8de1-dc9bb21ea984/collections/bastet/models"
jsonfolder="/srv/homes/pvc-b446e9d5-a1db-4b2d-8de1-dc9bb21ea984/scenes/bastet"
processedlist="/srv/processed_files.txt"
json_template="/srv/template.json"
relative_json_folder="bastet/models" 

# Crea il file della lista dei processati se non esiste già
touch "$processedlist"

# processo di estrazione e aggiornamento del file json
process_zip_and_update_json() {
  local zipfile=$1
  local filename=$(basename -- "$zipfile" .zip)

  if ! grep -Fxq "$filename.zip" "$processedlist"; then
    # Crea la cartella dove estrarre il file .zip
    mkdir -p "$extractionfolder/$filename"

    # Estrai il file .zip
    unzip -q "$zipfile" -d "$extractionfolder/$filename"

    local gltf_file=$(find "$extractionfolder/$filename" -name '*.gltf' -exec basename {} \;)

    if [ -n "$gltf_file" ]; then
      # Crea la cartella dove copiare il file .json
      mkdir -p "$jsonfolder/$filename"
      # Copia il file json nel jsonfolder
      local json_file_path="$jsonfolder/$filename/scene.json"
      cp "$json_template" "$json_file_path"

      # Sostituisci la stringa placeholder nel file JSON con il percorso corretto
      jq --arg path "$relative_json_folder/$filename/$gltf_file" '.scenegraph.nodes.main.urls = $path' "$json_file_path" > tmp.$$.json && mv tmp.$$.json "$json_file_path"

      # Marca il file zip come processato
      echo "$filename.zip" >> "$processedlist"
      echo "FILE PROCESSATO $filename.zip"
    else
      echo "Nessun file GLTF trovato in $zipfile"
    fi
  fi
}

# Loop principale
while true; do
  sleep 5  # Verifica ogni 5 secondi

  for f in "$dlfolder"/*.zip; do
    if [[ -f "$f" ]]; then
      process_zip_and_update_json "$f" &
    fi
  done
done