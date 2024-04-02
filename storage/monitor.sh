#!/bin/bash
# Percorsi delle cartelle
dlfolder="/srv/homes/pvc-b446e9d5-a1db-4b2d-8de1-dc9bb21ea984"
extractionfolder="/srv/homes/pvc-b446e9d5-a1db-4b2d-8de1-dc9bb21ea984/temp"
atonfolder="/srv/homes/pvc-b446e9d5-a1db-4b2d-8de1-dc9bb21ea984/collections/bastet/models"
dhopfolder="/srv/homes/pvc-b446e9d5-a1db-4b2d-8de1-dc9bb21ea984/dhop"
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

    local ply_file=$(find "$extractionfolder/$filename" -name '*.ply' -exec basename {} \;)

    if [ -n "$gltf_file" ]; then
      # sposta l'estrazione e sotto elementi nella cartella corretta
      mv "$extractionfolder/$filename" "$atonfolder/$filename"
      # Crea la cartella dove copiare il file .json
      mkdir -p "$jsonfolder/$filename"
      # Copia il file json nel jsonfolder
      local json_file_path="$jsonfolder/$filename/scene.json"
      cp "$json_template" "$json_file_path"

      # Sostituisci la stringa placeholder nel file JSON con il percorso corretto
      jq --arg path "$relative_json_folder/$filename/$gltf_file" '.scenegraph.nodes.main.urls = $path' "$json_file_path" > tmp.$$.json && mv tmp.$$.json "$json_file_path"

      # Imposta i permessi corretti
      chown -R  nobody:nogroup "$atonfolder/$filename"
      chown -R  nobody:nogroup "$jsonfolder/$filename"
      chomod -R 775 "$atonfolder/$filename"
      chomod -R 775 "$jsonfolder/$filename"

      # Marca il file zip come processato
      echo "$filename.zip" >> "$processedlist"
      echo "FILE PROCESSATO $filename.zip"
    else
      echo "Nessun file GLTF trovato in $zipfile"
    fi

    if [ -n "$ply_file" ]; then
      # sposta il contenuto l'estrazione e sotto elementi nella cartella corretta
      mv "$extractionfolder/$filename" "$dhopfolder"
      # rinomina il file ply
      mv "$dhopfolder/$filename/$ply_file" "$dhopfolder/$filename/$filename.ply"

      # Imposta i permessi corretti
      chown -R  nobody:nogroup "$dhopfolder/$filename"
      chmod -R 775 "$dhopfolder/$filename"

      # Marca il file zip come processato
      echo "$filename.zip" >> "$processedlist"
      echo "FILE PROCESSATO $filename.zip"
    else
      echo "Nessun file PLY trovato in $zipfile"
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