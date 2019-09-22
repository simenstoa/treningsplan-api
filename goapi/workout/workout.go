package workout

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/graphql-go/graphql"
	"goapi/airtable"
	gqlcommon "goapi/gql-common"
	"log"
)

type Workout struct {
	Id           string
	Name         string
	Purpose      string
	Description  string
	WorkoutBouts []string
}

type fields struct {
	Name         string   `json:"name,omitempty"`
	Purpose      string   `json:"purpose,omitempty"`
	Description  string   `json:"description,omitempty"`
	WorkoutBouts []string `json:"workoutBouts,omitempty"`
}

type privateWorkout struct {
	airtable.Client
}

func NewResolvable(airtableClient airtable.Client) gqlcommon.Resolvable {
	return privateWorkout{airtableClient}
}

func (i privateWorkout) GetAll() graphql.FieldResolveFn {
	return func(p graphql.ResolveParams) (interface{}, error) {
		var result results
		err := i.Client.GetAll(p.Context, airtable.Workout, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

func (i privateWorkout) Get() graphql.FieldResolveFn {
	return func(p graphql.ResolveParams) (interface{}, error) {
		id, err := gqlcommon.GetId(p)
		if err != nil {
			return nil, err
		}

		var result Workout
		err = i.Client.Get(p.Context, airtable.Workout, id, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

func (i privateWorkout) GetByIds(ctx context.Context, ids []string) (interface{}, error) {
	return nil, errors.New("not implemented")
}

func (i privateWorkout) GetById(ctx context.Context, id string) (interface{}, error) {
	return nil, errors.New("not implemented")
}

type results []Workout

func (res *results) MapAirtableResult(result airtable.AirtableResult) error {
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
	var fields fields
	err := json.Unmarshal(record.Fields, &fields)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}

	*res = Workout{
		Id:           record.Id,
		Name:         fields.Name,
		Description:  fields.Description,
		Purpose:      fields.Purpose,
		WorkoutBouts: fields.WorkoutBouts,
	}

	return nil
}
