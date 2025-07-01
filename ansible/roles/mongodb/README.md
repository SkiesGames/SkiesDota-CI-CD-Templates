# MongoDB Role

This Ansible role configures MongoDB with replica set initialization and index setup.

## Features

- **Replica Set Initialization**: Automatically initializes a MongoDB replica set
- **Index Management**: Creates optimized indexes for collections:
  - `active_actions`: Server number, action type, and bot selection indexes
  - `completed_operations`: TTL index for automatic cleanup and operation tracking
  - `cache_version`: Unique key index for cache management

## Tasks

### Main Tasks (`tasks/main.yml`)
- `init_replica_set.yml`: Initializes MongoDB replica set
- `setup_indexes.yml`: Creates database indexes

### Replica Set Initialization (`tasks/init_replica_set.yml`)
- Checks if replica set is already initialized
- Initializes replica set with primary and secondary nodes
- Waits for replica set to be ready

### Index Setup (`tasks/setup_indexes.yml`)
- Checks if indexes already exist
- Creates indexes for all collections with proper configurations

## Environment Variables

The role expects these environment variables for replica set configuration:
- `MONGO_HOST_1`: Primary node host
- `MONGO_HOST_2`: Secondary node host
- `MONGO_HOST_3`: Arbiter node host

## Files

- `files/setup_indexes.js`: MongoDB index creation script
- `templates/init_replica_set.js`: Replica set initialization script 