DROP TYPE films CASCADE;

create type films as (
film TEXT,
year INTEGER,
votes INTEGER,
rating REAL,
filmid TEXT
)

DROP TYPE IF EXISTS quality_class CASCADE;
CREATE TYPE quality_class AS ENUM ('star', 'good', 'average', 'bad');

drop table actors;

create table actors (
actorid TEXT,
actor TEXT,
current_year INTEGER,
films films[],
quality_class quality_class,
is_active BOOLEAN,
PRIMARY KEY (actorid, current_year)
);

select * from actors;