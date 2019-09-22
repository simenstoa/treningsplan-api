package bout

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/graphql-go/graphql"
	"goapi/airtable"
	gqlcommon "goapi/gql-common"
	"log"
)

type Bout struct {
	Id        string
	Name      string
	Duration  int
	Length    int
	Type      string
	Intensity []string
}

type fields struct {
	Name      string   `json:"name,omitempty"`
	Duration  int      `json:"duration,omitempty"`
	Length    int      `json:"length,omitempty"`
	Type      string   `json:"type,omitempty"`
	Intensity []string `json:"intensity,omitempty"`
}

type privateBout struct {
	airtable.Client
}

func NewResolvable(airtableClient airtable.Client) gqlcommon.Resolvable {
	return privateBout{airtableClient}
}

func (i privateBout) GetAll() graphql.FieldResolveFn {
	return func(p graphql.ResolveParams) (interface{}, error) {
		var result results
		err := i.Client.GetAll(p.Context, airtable.Bout, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

func (i privateBout) Get() graphql.FieldResolveFn {
	return func(p graphql.ResolveParams) (interface{}, error) {
		id, err := gqlcommon.GetId(p)
		if err != nil {
			return nil, err
		}

		var result Bout
		err = i.Client.Get(p.Context, airtable.Bout, id, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

func (i privateBout) GetByIds(ctx context.Context, ids []string) (interface{}, error) {
	return nil, errors.New("not implemented")
}

func (i privateBout) GetById(ctx context.Context, id string) (interface{}, error) {
	var result Bout
	err := i.Client.Get(ctx, airtable.Bout, id, &result)
	if err != nil {
		return nil, err
	}
	return result, nil
}

type results []Bout

func (res *results) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord Bout
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (res *Bout) MapAirtableRecord(record airtable.AirtableRecord) error {
	var fields fields
	err := json.Unmarshal(record.Fields, &fields)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}

	*res = Bout{
		Id:        record.Id,
		Name:      fields.Name,
		Length:    fields.Length,
		Duration:  fields.Duration,
		Type:      fields.Type,
		Intensity: fields.Intensity,
	}

	return nil
}