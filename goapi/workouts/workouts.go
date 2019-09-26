package workouts

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type Workout struct {
	Id           string   `json:"id"`
	Name         string   `json:"name,omitempty"`
	Purpose      string   `json:"purpose,omitempty"`
	Description  string   `json:"description,omitempty"`
	WorkoutBouts []string `json:"workoutBouts,omitempty"`
}

type Workouts []Workout

type privateWorkout struct {
	airtable.Client
}

type Resolvable interface {
	GetAll(ctx context.Context) (Workouts, error)
	Get(ctx context.Context, id string) (Workout, error)
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return privateWorkout{airtableClient}
}

func (i privateWorkout) GetAll(ctx context.Context) (Workouts, error) {
	var workouts Workouts
	err := i.Client.GetAll(ctx, airtable.Workout, &workouts)
	if err != nil {
		return Workouts{}, err
	}
	return workouts, nil
}

func (i privateWorkout) Get(ctx context.Context, id string) (Workout, error) {
	var result Workout
	err := i.Client.Get(ctx, airtable.Workout, id, &result)
	if err != nil {
		return Workout{}, err
	}
	return result, nil
}

func (res *Workouts) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord Workout
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (res *Workout) MapAirtableRecord(record airtable.AirtableRecord) error {
	var workout Workout
	err := json.Unmarshal(record.Fields, &workout)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}

	*res = Workout{
		Id:           record.Id,
		Name:         workout.Name,
		Description:  workout.Description,
		Purpose:      workout.Purpose,
		WorkoutBouts: workout.WorkoutBouts,
	}

	return nil
}
