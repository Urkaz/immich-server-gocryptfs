#!/bin/bash
set -e

# Needed environment variables:
# CRYPT_PASS: gocryptfs password
# MIGRATION_IMPORT_ENABLED, MIGRATION_IMPORT_DIR
# MIGRATION_EXPORT_ENABLED
CIPHER_DIR="/cipher"
CLEAR_DIR="/usr/src/app/upload"
BACKUPS_DIR="${CLEAR_DIR}/backups"
MIGRATION_BACKUPS_DIR="/migration_backups"
MIGRATION_IMPORT_DIR="/migration_import"
MIGRATION_EXPORT_DIR="/migration_export"

# Create dirs if they don't exist
mkdir -p "$CIPHER_DIR"
mkdir -p "$CLEAR_DIR"
chmod 755 "$CLEAR_DIR"
 
# Temp file with the encryption password
PASS_FILE=$(mktemp)
echo "$CRYPT_PASS" > "$PASS_FILE"
chmod 600 "$PASS_FILE"
trap 'rm -f "$PASS_FILE"' EXIT

# Create the backups folder outside the encrypted FS
mkdir -p "$BACKUPS_DIR"
touch "$BACKUPS_DIR/.immich"

# Create Immich folders with proper permissions
for d in encoded-video upload library thumbs profile; do
	CIPHER_SUBDIR="$CIPHER_DIR/$d"
    CLEAR_SUBDIR="$CLEAR_DIR/$d"
	
	mkdir -p "$CLEAR_SUBDIR"
	
	# Init gocryptfs
	if [ ! -f "$CIPHER_SUBDIR/gocryptfs.conf" ]; then
		gocryptfs -init -passfile "$PASS_FILE" -nosyslog "$CIPHER_SUBDIR"
	fi
	
	# Mount gocryptfs
	gocryptfs -passfile "$PASS_FILE" -allow_other -nosyslog "$CIPHER_SUBDIR" "$CLEAR_SUBDIR"

	touch "$CLEAR_SUBDIR/.immich"
done

# Optional migration from an existing Immich instance
MIGRATION_FLAG_IMPORT="$MIGRATION_BACKUPS_DIR/.migration_import_done"
if [ "$MIGRATION_IMPORT_ENABLED" = "true" ] && [ -d "$MIGRATION_IMPORT_DIR" ] && [ ! -f "$MIGRATION_FLAG_IMPORT" ]; then
    echo "Importing data from $MIGRATION_IMPORT_DIR..."

    # Backup current content
    PRE_MIGRATION_BACKUP="$MIGRATION_BACKUPS_DIR/pre_import_migration_$(date +%Y%m%d%H%M%S)"
    mkdir -p "$PRE_MIGRATION_BACKUP"
	echo "Backing up data to $PRE_MIGRATION_BACKUP..."
	
	# Backup before import
	for d in encoded-video upload library thumbs profile backups; do
        if [ -d "$CLEAR_DIR/$d" ]; then
            cp -a "$CLEAR_DIR/$d/." "$PRE_MIGRATION_BACKUP/$d/"
        fi
    done
	
	# Clean folders before import (ensures a fresh import)
    for d in encoded-video upload library thumbs profile backups; do
        rm -rf "$CLEAR_DIR/$d"/*
    done

    # Copy Immich folders from migration dir
    for d in encoded-video upload library thumbs profile backups; do
        if [ -d "$MIGRATION_IMPORT_DIR/$d" ]; then
            cp -a "$MIGRATION_IMPORT_DIR/$d/." "$CLEAR_DIR/$d/"
        fi
    done

    # Mark migration as done
    touch "$MIGRATION_FLAG_IMPORT"
    echo "Import migration completed."
fi

# --- Export migration ---
MIGRATION_FLAG_EXPORT="$MIGRATION_BACKUPS_DIR/.migration_export_done"
if [ "$MIGRATION_EXPORT_ENABLED" = "true" ] && [ -d "$MIGRATION_BACKUPS_DIR" ] && [ ! -f "$MIGRATION_FLAG_EXPORT" ]; then
    
    PRE_MIGRATION_BACKUP="$MIGRATION_BACKUPS_DIR/export_migration_$(date +%Y%m%d%H%M%S)"
    mkdir -p "$PRE_MIGRATION_BACKUP"
	echo "Backing up data to $PRE_MIGRATION_BACKUP..."

    for d in encoded-video upload library thumbs profile backups; do
        if [ -d "$CLEAR_DIR/$d" ]; then
            cp -a "$CLEAR_DIR/$d/." "$PRE_MIGRATION_BACKUP/$d/"
        fi
    done

    # Mark export as done
    touch "$MIGRATION_FLAG_EXPORT"
    echo "Export migration completed."
fi

# Run Immich
exec "start.sh"
