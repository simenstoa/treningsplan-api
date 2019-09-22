package workoutbouts

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/graphql-go/graphql"
	"goapi/airtable"
	gqlcommon "goapi/gql-common"
	"log"
)

type WorkoutBouts struct {
	Id      string
	Workout []string
	Bout    []string
	Order   int
}

type fields struct {
	Workout []string `json:"workout,omitempty"`
	Bout    []string `json:"bout,omitempty"`
	Order   int      `json:"order,omitempty"`
}

type privateWorkoutBouts struct {
	airtable.Client
}

func NewResolvable(airtableClient airtable.Client) gqlcommon.Resolvable {
	return privateWorkoutBouts{airtableClient}
}

func (i privateWorkoutBouts) GetAll() graphql.FieldResolveFn {
	return func(p graphql.ResolveParams) (interface{}, error) {
		var result Result
		err := i.Client.GetAll(p.Context, airtable.Workout, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

func (i privateWorkoutBouts) Get() graphql.FieldResolveFn {
	return func(p graphql.ResolveParams) (interface{}, error) {
		id, err := gqlcommon.GetId(p)
		if err != nil {
			return nil, err
		}

		var result WorkoutBouts
		err = i.Client.Get(p.Context, airtable.WorkoutBouts, id, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

func (i privateWorkoutBouts) GetByIds(ctx context.Context, ids []string) (interface{}, error) {
	var result Result
	for _, id := range ids {
		var workoutBouts WorkoutBouts
		err := i.Client.Get(ctx, airtable.WorkoutBouts, id, &workoutBouts)
		if err != nil {
			return nil, err
		}
		result = append(result, workoutBouts)
	}

	return result, nil
}

func (i privateWorkoutBouts) GetById(ctx context.Context, id string) (interface{}, error) {
	return nil, errors.New("not implemented")
}

type Result []WorkoutBouts

func (res *Result) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord WorkoutBouts
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (res *WorkoutBouts) MapAirtableRecord(record airtable.AirtableRecord) error {
	var fields fields
	err := json.Unmarshal(record.Fields, &fields)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}

	*res = WorkoutBouts{
		Id:      record.Id,
		Workout: fields.Workout,
		Bout:    fields.Bout,
		Order:   fields.Order,
	}

	return nil
}
