CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE IF NOT EXISTS placemarker_types (
    slug VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

INSERT INTO placemarker_types (slug, name) VALUES 
    ('default', 'default'),
    ('residential', 'жилая недвижимость'),
    ('commercial', 'коммерческая недвижимость'),
    ('parking', 'парковка'),
    ('cafe', 'кафе'),
    ('restaurant', 'ресторан'),
    ('museum', 'музей'),
    ('marketplace', 'Пункт выдачи marketplace')
ON CONFLICT (slug) DO NOTHING;

CREATE TABLE IF NOT EXISTS tags (
    id UUID PRIMARY KEY,
    user_uuid UUID NOT NULL,
    type_id VARCHAR(50) NOT NULL REFERENCES placemarker_types(slug) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS tags_user_uuid_idx ON tags (user_uuid);
CREATE INDEX IF NOT EXISTS tags_user_type_idx ON tags (user_uuid, type_id);

CREATE TABLE IF NOT EXISTS placemarkers (
    id UUID PRIMARY KEY,
    user_uuid UUID NOT NULL,
    type_id VARCHAR(50) NOT NULL DEFAULT 'default' REFERENCES placemarker_types(slug) ON DELETE SET DEFAULT,
    name VARCHAR(255) NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lon DOUBLE PRECISION NOT NULL,
    description TEXT,
    tags_jsonb JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    geom geography(Point, 4326) GENERATED ALWAYS AS (ST_SetSRID(ST_MakePoint(lon, lat), 4326)::geography) STORED
);

CREATE INDEX IF NOT EXISTS placemarkers_geom_idx ON placemarkers USING GIST (geom);
CREATE INDEX IF NOT EXISTS placemarkers_user_uuid_idx ON placemarkers (user_uuid);
CREATE INDEX IF NOT EXISTS placemarkers_type_id_idx ON placemarkers (type_id);
CREATE INDEX IF NOT EXISTS placemarkers_tags_jsonb_idx ON placemarkers USING GIN (tags_jsonb);
