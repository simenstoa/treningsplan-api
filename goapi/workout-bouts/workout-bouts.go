package workoutbouts

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type WorkoutBout struct {
	Id      string   `json:"id"`
	Workout []string `json:"workout,omitempty"`
	Bout    []string `json:"bout,omitempty"`
	Order   int      `json:"order,omitempty"`
}

type WorkoutBouts []WorkoutBout

type Resolvable interface {
	GetByParentId(ctx context.Context, parentId string) (WorkoutBouts, error)
}

type privateWorkoutBouts struct {
	airtable.Client
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return privateWorkoutBouts{airtableClient}
}

func (i privateWorkoutBouts) GetByParentId(ctx context.Context, parentId string) (WorkoutBouts, error) {
	var result WorkoutBouts
	err := i.Client.GetByParentId(ctx, airtable.WorkoutBouts, airtable.Workout, parentId, &result)
	if err != nil {
		return nil, err
	}
	return result, nil
}


func (res *WorkoutBouts) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var workoutBout WorkoutBout
		err := workoutBout.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, workoutBout)
	}
	return nil
}

func (res *WorkoutBout) MapAirtableRecord(record airtable.AirtableRecord) error {
	err := json.Unmarshal(record.Fields, res)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}
	return nil
}
