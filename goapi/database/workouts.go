package database

import (
	"context"
	"database/sql"
	"goapi/logger"
	"goapi/models"
	"sort"
)

type workoutClient interface {
	GetWorkouts(ctx context.Context) ([]models.Workout, error)
	GetWorkout(ctx context.Context, id string) (models.Workout, error)
	CreateWorkout(ctx context.Context, name, description, createdById string) (models.Workout, error)
	GetWorkoutPartsForWorkout(ctx context.Context, workoutId string) ([]models.WorkoutPart, error)
	AddWorkoutPart(ctx context.Context, workoutId string, order int, distance int, metric, intensityId, createdById string) (models.Workout, error)
}

func (c *client) CreateWorkout(ctx context.Context, name, description, createdById string) (models.Workout, error) {
	log := logger.FromContext(ctx)

	id := createNewId()

	sqlStatement :=
		`INSERT INTO workout (workout_uid, name, description, created_by_uid)
			VALUES ($1, $2, $3, $4)`

	_, err := c.db.Exec(sqlStatement, id, name, description, createdById)
	if err != nil {
		log.WithError(err).Error("error during insert to db")
		return models.Workout{}, err
	}

	return c.GetWorkout(ctx, id)
}

func (c *client) AddWorkoutPart(ctx context.Context, workoutId string, order, distance int, metric, intensityId, createdById string) (models.Workout, error) {
	log := logger.FromContext(ctx)

	sqlStatement :=
		`INSERT INTO workout_parts (workout_uid, "order", distance, metric, intensity_uid, created_by_uid)
			VALUES ($1, $2, $3, $4, $5, $6)`

	_, err := c.db.Exec(sqlStatement, workoutId, order, distance, metric, intensityId, createdById)
	if err != nil {
		log.WithError(err).Error("error during insert to db")
		return models.Workout{}, err
	}

	return c.GetWorkout(ctx, workoutId)
}

func (c *client) GetWorkouts(ctx context.Context) ([]models.Workout, error) {
	log := logger.FromContext(ctx)

	sqlStatement :=
		`SELECT 
       			w.workout_uid, w.name, w.description, w.created_by_uid
				FROM workout AS w;`

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

	var workouts []models.Workout
	for rows.Next() {
		var workout models.Workout
		err = rows.Scan(
			&workout.Id, &workout.Name, &workout.Description, &workout.CreatedBy,
		)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return []models.Workout{}, err
		}

		workouts = append(workouts, workout)
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return []models.Workout{}, err
	}

	return workouts, nil
}

func (c *client) GetWorkout(ctx context.Context, id string) (models.Workout, error) {
	log := logger.FromContext(ctx)

	sqlStatement :=
		`SELECT 
       			w.workout_uid, w.name, w.description, w.created_by_uid
				FROM workout AS w
				WHERE w.workout_uid = $1`

	row := c.db.QueryRowContext(ctx, sqlStatement, id)
	var workout models.Workout
	err := row.Scan(&workout.Id, &workout.Name, &workout.Description, &workout.CreatedBy)
	if err != nil {
		if err == sql.ErrNoRows {
			notFoundError := newEntityNotFoundError(err)
			log.WithError(notFoundError).Error("Workout not found")
			return models.Workout{}, notFoundError
		}
		log.WithError(err).Error("Error while parsing db row")
		return models.Workout{}, err
	}

	return workout, nil
}

func (c *client) GetWorkoutPartsForWorkout(ctx context.Context, workoutId string) ([]models.WorkoutPart, error) {
	log := logger.FromContext(ctx)

	sqlStatement :=
		`SELECT wp."order", wp.distance, wp.metric,
       			i.intensity_uid, i.name, i.description, i.coefficient 
				FROM workout_parts AS wp
			    LEFT JOIN intensity as i USING(intensity_uid)
				WHERE wp.workout_uid = $1;`

	rows, err := c.db.QueryContext(ctx, sqlStatement, workoutId)
	if err != nil {
		log.WithError(err).Error("Error querying db")
		return []models.WorkoutPart{}, err
	}
	defer func() {
		err := rows.Close()
		if err != nil {
			log.WithError(err).Error("Error closing db query connection")
		}
	}()

	var workoutParts []models.WorkoutPart
	for rows.Next() {
		var workoutPart models.WorkoutPart
		var intensity models.Intensity
		err = rows.Scan(
			&workoutPart.Order, &workoutPart.Distance, &workoutPart.Metric,
			&intensity.Id, &intensity.Name, &intensity.Description, &intensity.Coefficient,
		)
		if err != nil {
			log.WithError(err).Error("Error while parsing db row")
			return []models.WorkoutPart{}, err
		}

		workoutPart.Intensity = intensity
		workoutParts = append(workoutParts, workoutPart)
	}
	// get any error encountered during iteration
	err = rows.Err()
	if err != nil {
		log.WithError(err).Error("Error while parsing db rows")
		return []models.WorkoutPart{}, err
	}

	sort.Slice(workoutParts, func(i, j int) bool {
		return workoutParts[i].Order < workoutParts[j].Order
	})

	return workoutParts, nil
}
