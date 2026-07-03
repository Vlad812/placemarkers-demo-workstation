
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE user_role AS ENUM ('admin', 'user');

CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'user',
    is_active BOOLEAN NOT NULL DEFAULT false,
    email_verification_token VARCHAR(128) UNIQUE,
    password_reset_token VARCHAR(128) UNIQUE,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(128) NOT NULL UNIQUE,
    family UUID NOT NULL, -- семейство токенов для отслеживания
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    used_at TIMESTAMP WITH TIME ZONE -- когда был использован (для rotation)
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_family ON refresh_tokens(family);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);

-- Тестовый пользователь (пароль: 12345678)
INSERT INTO users (id, email, password_hash, role, is_active, email_verification_token, password_reset_token, email_verified_at, created_at, updated_at)
VALUES (
     gen_random_uuid(),
    'test@example.com',
    '$2y$12$gQN7L5SeoIlKeS95TeiSOO0NQTb3t9Lq7ysgntikow0kdgCJfkdzC',
    'user',
    true,
    null,
    null,
    NOW(),
    NOW(),
    NOW()
);