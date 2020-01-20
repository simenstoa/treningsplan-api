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
	"goapi/models"
	"sort"
)

type Client interface {
	Close() error
	GetIntensities(ctx context.Context) ([]models.Intensity, error)
	GetWorkouts(ctx context.Context) ([]models.Workout, error)
	GetWorkout(ctx context.Context, id string) (models.Workout, error)
	GetProfiles(ctx context.Context) ([]models.Profile, error)
	GetProfile(ctx context.Context, id string) (models.Profile, error)
	GetProfileByAuth0Id(ctx context.Context, auth0Id string) (models.Profile, error)
	GetRecords(ctx context.Context, profileId string) ([]models.Record, error)
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

func (c *client) GetIntensities(ctx context.Context) ([]models.Intensity, error) {
	log := logger.FromContext(ctx)

	sqlStatement := `SELECT intensity_uid, name, description, coefficient FROM Intensity;`

	rows, err := c.db.Query(sqlStatement)
	if err != nil {
		log.WithError(err).Error("Error querying db")
		return []models.Intensity{}, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			log.WithError(err).Error("Error closing db query connection")
		}
	}()

	var intensities []models.Intensity
	for rows.Next() {
		var intensity models.Intensity
		err = rows.Scan(&intensity.Id, &intensity.Name, &intensity.Description, &intensity.Coefficient)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return []models.Intensity{}, err
		}
		intensities = append(intensities, intensity)
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return []models.Intensity{}, err
	}

	return intensities, nil
}

func (c *client) GetWorkouts(ctx context.Context) ([]models.Workout, error) {
	log := logger.FromContext(ctx)

	sqlStatement :=
		`SELECT 
       			w.workout_uid, w.name, w.description, w.created_by_uid,
       			wp."order", wp.distance, wp.metric,
       			i.intensity_uid, i.name, i.description, i.coefficient 
				FROM workout AS w 
			    JOIN workout_parts AS wp USING(workout_uid) 
			    JOIN intensity as i USING(intensity_uid);`

	rows, err := c.db.QueryContext(ctx, sqlStatement)
	if err != nil {
		log.WithError(err).Error("Error querying db")
		return []models.Workout{}, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			log.WithError(err).Error("Error closing db query connection")
		}
	}()

	workouts := make(map[string]models.Workout)
	for rows.Next() {
		var workout models.Workout
		var part models.WorkoutPart
		var intensity models.Intensity
		err = rows.Scan(
			&workout.Id, &workout.Name, &workout.Description, &workout.CreatedBy,
			&part.Order, &part.Distance, &part.Metric,
			&intensity.Id, &intensity.Name, &intensity.Description, &intensity.Coefficient,
		)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return []models.Workout{}, err
		}

		part.Intensity = intensity
		if existingWorkout, ok := workouts[workout.Id]; ok {
			existingWorkout.Parts = append(existingWorkout.Parts, part)
			workouts[workout.Id] = existingWorkout
		} else {
			workout.Parts = append(workout.Parts, part)
			workouts[workout.Id] = workout
		}
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return []models.Workout{}, err
	}

	var workoutList []models.Workout
	for _, workout := range workouts {
		sort.Slice(workout.Parts, func(i, j int) bool {
			return workout.Parts[i].Order < workout.Parts[j].Order
		})
		workoutList = append(workoutList, workout)
	}

	return workoutList, nil
}

func (c *client) GetWorkout(ctx context.Context, id string) (models.Workout, error) {
	log := logger.FromContext(ctx)

	sqlStatement :=
		`SELECT 
       			w.workout_uid, w.name, w.description, w.created_by_uid,
       			wp."order", wp.distance, wp.metric,
       			i.intensity_uid, i.name, i.description, i.coefficient 
				FROM workout AS w 
			    JOIN workout_parts AS wp USING(workout_uid) 
			    JOIN intensity as i USING(intensity_uid)
				WHERE w.workout_uid = $1;`

	rows, err := c.db.QueryContext(ctx, sqlStatement, id)
	if err != nil {
		log.WithError(err).Error("Error querying db")
		return models.Workout{}, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			log.WithError(err).Error("Error closing db query connection")
		}
	}()

	var workout models.Workout
	for rows.Next() {
		var part models.WorkoutPart
		var intensity models.Intensity
		err = rows.Scan(
			&workout.Id, &workout.Name, &workout.Description, &workout.CreatedBy,
			&part.Order, &part.Distance, &part.Metric,
			&intensity.Id, &intensity.Name, &intensity.Description, &intensity.Coefficient,
		)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return models.Workout{}, err
		}

		part.Intensity = intensity
		workout.Parts = append(workout.Parts, part)
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return models.Workout{}, err
	}

	sort.Slice(workout.Parts, func(i, j int) bool {
		return workout.Parts[i].Order < workout.Parts[j].Order
	})

	return workout, nil
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