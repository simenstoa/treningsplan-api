package database

import (
	"context"
	"goapi/logger"
	"goapi/models"
	"sort"
)

type workoutClient interface {
	GetWorkouts(ctx context.Context) ([]models.Workout, error)
	GetWorkout(ctx context.Context, id string) (models.Workout, error)
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
