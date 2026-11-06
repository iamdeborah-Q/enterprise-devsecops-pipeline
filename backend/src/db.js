
const fs = require('node:fs'); // ADDED
const { Pool } = require('pg');

// ADDED: Read credentials from Kubernetes Secret files
function readSecret(filePath, envName) {
  if (filePath) {
    return fs.readFileSync(filePath, 'utf8').trimEnd();
  }

  return process.env[envName];
}

const pool = new Pool({
  user: readSecret(process.env.DB_USER_FILE, 'DB_USER'), // FIXED
  password: readSecret(process.env.DB_PASSWORD_FILE, 'DB_PASSWORD'), // FIXED
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT, 10),
  database: readSecret(process.env.DB_NAME_FILE, 'DB_NAME'), // FIXED
});

async function initDB() {
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS posts (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        content TEXT NOT NULL,
        author VARCHAR(100) NOT NULL DEFAULT 'Anonymous',
        emoji VARCHAR(10) DEFAULT '✨',
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS comments (
        id SERIAL PRIMARY KEY,
        post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
        author VARCHAR(100) NOT NULL DEFAULT 'Anonymous',
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    console.log('✅ Database tables initialized');
  } finally {
    client.release();
  }
}

module.exports = { pool, initDB };
