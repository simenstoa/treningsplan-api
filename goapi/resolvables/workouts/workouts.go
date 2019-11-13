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
	Distance     int      `json:"distance,omitempty"`
	Recipe       string   `json:"recipe,omitempty"`
}

type Workouts []Workout

type resolvable struct {
	airtable.Client
}

type Resolvable interface {
	GetAll(ctx context.Context) (Workouts, error)
	Get(ctx context.Context, id string) (Workout, error)
	GetByIds(ctx context.Context, ids []string) (Workouts, error)
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return resolvable{airtableClient}
}

func (r resolvable) GetAll(ctx context.Context) (Workouts, error) {
	var workouts Workouts
	err := r.Client.GetAll(ctx, airtable.Workout, &workouts)
	if err != nil {
		return Workouts{}, err
	}
	return workouts, nil
}

func (r resolvable) GetByIds(ctx context.Context, ids []string) (Workouts, error) {
	var workouts Workouts
	err := r.Client.GetByIds(ctx, airtable.Workout, ids, &workouts)
	if err != nil {
		return Workouts{}, err
	}
	return workouts, nil
}

func (r resolvable) Get(ctx context.Context, id string) (Workout, error) {
	var result Workout
	err := r.Client.Get(ctx, airtable.Workout, id, &result)
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
	err := json.Unmarshal(record.Fields, res)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}

	return nil
}
