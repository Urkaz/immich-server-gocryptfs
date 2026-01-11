# Immich with gocryptfs encryption

This is the standard [Immich](https://github.com/immich-app/immich) Docker container, enhanced with a **[gocryptfs](https://github.com/rfjakob/gocryptfs) encryption layer**. It encrypts all files as they are saved to your file system, ensuring that all your Immich photos and videos remain private. Even if someone has access to your file system, they won’t be able to view your content.

## Usage

Use the [docker_compose.yml](https://github.com/Urkaz/immich-server-gocryptfs/blob/main/docker-compose.yml) and [example.env](https://github.com/Urkaz/immich-server-gocryptfs/blob/main/example.env) files to run and configure it.

Using them by default, encrypts the data from the folders: "library", "upload", "thumbs", "profile", "encoded-video". While it keeps the "backup" folder as not encrypted.

New environment variables:

| Env var  | Description | Default value |
| ------------- | ------------- | ------------- |
| ENCRYPTED_LOCATION  | Folder with all encrypted data. By default it includes the following Immich folders: "library", "upload", "thumbs", "profile", "encoded-video". | ./data_encrypted |
| UNENCRYPTED_LOCATION  | Folder with unencrypted data. By default it includes the following Immich folders: "backup" | ./data_unencrypted |
| CRYPT_PASS | **gocryptfs master password**. Please use only the characters `A-Za-z0-9`, without special characters or spaces. Change it to a safe password and **don't forget it or you will lose your data**! | gocryptfs_password |
| MIGRATION_IMPORT_LOCATION | Check sections below | ./migration_import |
| MIGRATION_IMPORT_ENABLED | Check sections below | false |
| MIGRATION_BACKUPS_LOCATION | Check sections below | ./migration_backups |
| MIGRATION_EXPORT_ENABLED | Check sections below | false |

## Migrating from a regular Immich-server instance to this

> [!CAUTION]
> Please backup your current Immich data before using this feature.

WIP.

## Migrating from this to a regular Immich-server instance

> [!CAUTION]
> Please backup your current Immich data before using this feature.

WIP.


