package database

import (
	"context"
	"database/sql"
	"fmt"
	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/lib/pq"
	"goapi/config"
	"goapi/logger"
)

type Client interface {
	Close() error
	intensityClient
	workoutClient
	profileClient
}

type client struct {
	db *sql.DB
}

func NewClient(ctx context.Context, cfg config.Config) (Client, error) {
	log := logger.FromContext(ctx)

	log.Info("Connecting to db")
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		cfg.PostgresHost, cfg.PostgresPort, cfg.PostgresUser, cfg.PostgresPassword, cfg.PostgresName)

	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		log.WithError(err).Error("Error while opening db connection")
		return nil, err
	}

	log.Info("Testing db connection")
	err = db.PingContext(ctx)
	if err != nil {
		log.WithError(err).Error("Error while testing db connection")
		return nil, err
	}

	log.Info("Running database migrations")
	driver, err := postgres.WithInstance(db, &postgres.Config{})
	m, err := migrate.NewWithDatabaseInstance(
		"file://database/migrations",
		cfg.PostgresName, driver)
	if err != nil {
		log.WithError(err).Error("Could not init migration")
		return nil, err
	}
	err = m.Up()
	if err != nil {
		if err != migrate.ErrNoChange {
			log.WithError(err).Error("Error during migration")
			return nil, err
		}
	}

	return &client{
		db: db,
	}, nil
}

func (c *client) Close() error {
	return c.db.Close()
}
