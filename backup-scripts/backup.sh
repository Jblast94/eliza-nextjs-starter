#!/bin/bash

# Supabase Database Backup Script
# This script creates automated backups of the Supabase PostgreSQL database

set -e

# Configuration
BACKUP_DIR="/backups"
RETENTION_DAYS=30
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/supabase_backup_${DATE}.sql"
LOG_FILE="${BACKUP_DIR}/backup.log"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to create backup
create_backup() {
    log "Starting backup process..."
    
    # Create the backup
    if pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" > "$BACKUP_FILE"; then
        log "Backup created successfully: $BACKUP_FILE"
        
        # Compress the backup
        if gzip "$BACKUP_FILE"; then
            log "Backup compressed successfully: ${BACKUP_FILE}.gz"
        else
            log "Warning: Failed to compress backup file"
        fi
    else
        log "Error: Failed to create backup"
        exit 1
    fi
}

# Function to clean old backups
cleanup_old_backups() {
    log "Cleaning up backups older than $RETENTION_DAYS days..."
    
    find "$BACKUP_DIR" -name "supabase_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
    
    log "Cleanup completed"
}

# Function to verify backup
verify_backup() {
    local backup_file="${BACKUP_FILE}.gz"
    
    if [ -f "$backup_file" ]; then
        local file_size=$(stat -c%s "$backup_file")
        if [ "$file_size" -gt 1024 ]; then  # At least 1KB
            log "Backup verification passed: $backup_file ($file_size bytes)"
        else
            log "Warning: Backup file seems too small: $backup_file ($file_size bytes)"
        fi
    else
        log "Error: Backup file not found: $backup_file"
        exit 1
    fi
}

# Main execution
main() {
    log "=== Starting Supabase Backup Process ==="
    
    # Check required environment variables
    if [ -z "$PGHOST" ] || [ -z "$PGPORT" ] || [ -z "$PGUSER" ] || [ -z "$PGDATABASE" ] || [ -z "$PGPASSWORD" ]; then
        log "Error: Missing required environment variables"
        exit 1
    fi
    
    create_backup
    verify_backup
    cleanup_old_backups
    
    log "=== Backup Process Completed Successfully ==="
}

# Run main function
main "$@"