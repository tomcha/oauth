CREATE TABLE IF NOT EXISTS oauth_users(
  id INTEGER PRIMARY KEY NOT NULL,
  twitter_id INTEGER NOT NULL,
  user_name TEXT NOT NULL,
  created_at text NOT NULL,
  updated_at text NOT NULL
);
