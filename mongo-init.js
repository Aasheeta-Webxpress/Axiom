// MongoDB initialization script
db = db.getSiblingDB('axiom');

// Create collections with validation
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['email', 'password', 'createdAt'],
      properties: {
        email: {
          bsonType: 'string',
          pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        },
        password: {
          bsonType: 'string',
          minLength: 6
        },
        createdAt: {
          bsonType: 'date'
        }
      }
    }
  }
});

db.createCollection('projects', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'userId', 'createdAt'],
      properties: {
        name: {
          bsonType: 'string',
          minLength: 1
        },
        userId: {
          bsonType: 'objectId'
        },
        createdAt: {
          bsonType: 'date'
        }
      }
    }
  }
});

db.createCollection('widgets');
db.createCollection('forms');
db.createCollection('workflows');

// Create indexes for better performance
db.users.createIndex({ email: 1 }, { unique: true });
db.projects.createIndex({ userId: 1 });
db.projects.createIndex({ createdAt: -1 });

// Insert initial admin user (password: admin123)
db.users.insertOne({
  email: 'admin@axiom.com',
  password: '$2a$10$rOzJqQjQjQjQjQjQjQjQjOzJqQjQjQjQjQjQjQjQjQjQjQjQjQjQjQ',
  role: 'admin',
  createdAt: new Date()
});

print('MongoDB initialized successfully');
