package database

import (
	"context"
	"database/sql"
	"goapi/logger"
	"goapi/models"
)

type profileClient interface {
	GetProfiles(ctx context.Context) ([]models.Profile, error)
	GetProfile(ctx context.Context, id string) (models.Profile, error)
	GetProfileByAuth0Id(ctx context.Context, auth0Id string) (models.Profile, error)
	GetRecords(ctx context.Context, profileId string) ([]models.Record, error)
}

func (c *client) GetProfiles(ctx context.Context) ([]models.Profile, error) {
	log := logger.FromContext(ctx)

	sqlStatement := `SELECT profile_uid, first_name, last_name, vdot FROM profile;`

	rows, err := c.db.Query(sqlStatement)
	if err != nil {
		log.WithError(err).Error("Error querying db")
		return []models.Profile{}, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			log.WithError(err).Error("Error closing db query connection")
		}
	}()

	var profiles []models.Profile
	for rows.Next() {
		var profile models.Profile
		err = rows.Scan(&profile.Id, &profile.FirstName, &profile.LastName, &profile.Vdot)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return []models.Profile{}, err
		}
		profiles = append(profiles, profile)
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return []models.Profile{}, err
	}

	return profiles, nil
}

func (c *client) GetProfile(ctx context.Context, id string) (models.Profile, error) {
	log := logger.FromContext(ctx)

	sqlStatement :=
		`SELECT profile_uid, first_name, last_name, vdot FROM profile WHERE profile_uid = $1;`

	row := c.db.QueryRowContext(ctx, sqlStatement, id)
	var profile models.Profile
	err := row.Scan(&profile.Id, &profile.FirstName, &profile.LastName, &profile.Vdot)
	if err != nil {
		if err == sql.ErrNoRows {
			notFoundError := newEntityNotFoundError(err)
			log.WithError(notFoundError).Error("Profile not found")
			return models.Profile{}, notFoundError
		}
		log.WithError(err).Error("Error while parsing db row")
		return models.Profile{}, err
	}

	return profile, nil
}

func (c *client) GetProfileByAuth0Id(ctx context.Context, auth0Id string) (models.Profile, error) {
	log := logger.FromContext(ctx)

	sqlStatement :=
		`SELECT profile_uid, first_name, last_name, vdot FROM profile WHERE auth0_id = $1;`

	row := c.db.QueryRowContext(ctx, sqlStatement, auth0Id)
	var profile models.Profile
	err := row.Scan(&profile.Id, &profile.FirstName, &profile.LastName, &profile.Vdot)
	if err != nil {
		if err == sql.ErrNoRows {
			notFoundError := newEntityNotFoundError(err)
			log.WithError(notFoundError).Error("Profile not found")
			return models.Profile{}, notFoundError
		}
		log.WithError(err).Error("Error while parsing db row")
		return models.Profile{}, err
	}

	return profile, nil
}

func (c *client) GetRecords(ctx context.Context, profileId string) ([]models.Record, error) {
	log := logger.FromContext(ctx)

	sqlStatement := `SELECT record_uid, race, duration FROM record WHERE profile_uid=$1;`

	rows, err := c.db.Query(sqlStatement, profileId)
	if err != nil {
		log.WithError(err).Error("Error querying db")
		return []models.Record{}, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			log.WithError(err).Error("Error closing db query connection")
		}
	}()

	var records []models.Record
	for rows.Next() {
		var record models.Record
		err = rows.Scan(&record.Id, &record.Race, &record.Duration)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return []models.Record{}, err
		}
		records = append(records, record)
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return []models.Record{}, err
	}

	return records, nil
}