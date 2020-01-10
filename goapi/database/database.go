package database

import (
	"context"
	"database/sql"
	"fmt"
	"goapi/config"
	"goapi/logger"

	_ "github.com/lib/pq"
)

type Client interface {
	Close() error
	GetIntensities(ctx context.Context) ([]Intensity, error)
}

type client struct {
	db *sql.DB
}

func NewClient(ctx context.Context, cfg config.Config) (Client, error) {
	log := logger.FromContext(ctx)

	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		cfg.PostgresHost, cfg.PostgresPort, cfg.PostgresUser, cfg.PostgresPassword, cfg.PostgresName)

	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		log.WithError(err).Error("Error while opening db connection")
		return nil, err
	}

	err = db.PingContext(ctx)
	if err != nil {
		log.WithError(err).Error("Error while testing db connection")
		return nil, err
	}

	return &client{
		db: db,
	}, nil
}

func (c *client) Close() error {
	return c.db.Close()
}

func (c *client) GetIntensities(ctx context.Context) ([]Intensity, error) {
	log := logger.FromContext(ctx)

	sqlStatement := `SELECT intensity_uid, name, description, coefficient FROM intensity;`

	rows, err := c.db.Query(sqlStatement)
	if err != nil {
		log.WithError(err).Error("Error querying db")
		return []Intensity{}, err
	}
	defer func() {
		err := rows.Close()
		log.WithError(err).Error("Error closing db query connection")
	}()

	var intensities []Intensity
	for rows.Next() {
		var intensity Intensity
		err = rows.Scan(&intensity.Id, &intensity.Name, &intensity.Description, &intensity.Coefficient)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return []Intensity{}, err
		}
		intensities = append(intensities, intensity)
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return []Intensity{}, err
	}

	return intensities, nil
}
