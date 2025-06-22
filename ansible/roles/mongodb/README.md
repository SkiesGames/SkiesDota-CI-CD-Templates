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

## Testing with Molecule

The role includes comprehensive testing using Molecule with template-based configuration:

### Test Structure
```
molecule/default/
├── prepare.yml       # Environment setup (MongoDB container)
└── verify.yml        # Verification tests
```

### Running Tests

#### Local Testing
```bash
cd ansible/roles/mongodb
molecule test
```

#### GitLab CI
Tests run automatically on main branch commits when `AUTO_DEPLOY=true` and can be triggered manually.

### Test Coverage

The verification tests check:
- MongoDB container is running
- Replica set is properly initialized
- All required indexes exist on collections:
  - `active_actions`: ≥3 indexes
  - `completed_operations`: ≥2 indexes  
  - `cache_version`: ≥1 index

## Environment Variables

The role expects these environment variables for replica set configuration:
- `MONGO_HOST_1`: Primary node host
- `MONGO_HOST_2`: Secondary node host
- `MONGO_HOST_3`: Arbiter node host

## Files

- `files/setup_indexes.js`: MongoDB index creation script
- `templates/init_replica_set.js`: Replica set initialization script
- `molecule/default/prepare.yml`: Test environment setup
- `molecule/default/verify.yml`: Test verification 