// Create indexes for active_actions collection
db.active_actions.createIndex({ "server_number": 1, "action_type": 1, "selected_bots": 1, "delay": 1 }, { unique: true });
db.active_actions.createIndex({ "server_number": 1 });
db.active_actions.createIndex({ "action_type": 1 });

// Create indexes for completed_operations collection
db.completed_operations.createIndex({ "created_at": 1 }, { expireAfterSeconds: 86400 }); // 1 day TTL
db.completed_operations.createIndex({ "operation_id": 1 }, { unique: true });

// Create indexes for cache_version collection
db.cache_version.createIndex({ "key": 1 }, { unique: true }); 