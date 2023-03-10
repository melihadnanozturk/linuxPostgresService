#!/bin/bash

DB_HOST=localhost
DB_USER=postgres
DB_PASS=v8754367Q
DB_NAME=postgres

# Veritabanında dosya tablosunun olup olmadığını kontrol eder
# Eğer yoksa oluşturur
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "CREATE TABLE IF NOT EXISTS dizi (name text, createdtime timestamptz, deleted boolean DEFAULT false, deletedtime timestamptz);"

# Dizin için olayları izler
inotifywait -m -e create -e delete --format '%e %f' /home/adnan/Desktop | while read file; do

  # Geçerli zamanı alır
  now=$(date -Iseconds)

  # Olayın dosya oluşturma veya silme olup olmadığını kontrol eder
  if [[ $file = *"CREATE"* ]]; then

    # Dosya oluşturulduysa, veritabanına kayıt ekler
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "INSERT INTO dizi (name, createdtime) VALUES ('$(echo "$file" | cut -d' ' -f2)', '$now');"
  elif [[ $file = *"DELETE"* ]]; then

    # Dosya silindiyse, veritabanındaki dosya adına karşılık gelen silindi bilgisini true olarak ayarlar ayrıca silinme zamanını da ekler
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "UPDATE dizi SET deleted=true, deletedtime='$now' WHERE name='$(echo "$file" | cut -d' ' -f2)';"
  fi
done
