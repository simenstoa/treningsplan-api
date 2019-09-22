package intensity

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/graphql-go/graphql"
	"goapi/airtable"
	gqlcommon "goapi/gql-common"
	"log"
)

type intensityZone struct {
	Id            string
	Name          string
	Description   string
	IntensityType string
}

type fields struct {
	Name          string `json:"name,omitempty"`
	Description   string `json:"description,omitempty"`
	IntensityType string `json:"type,omitempty"`
}

type privateIntensity struct {
	airtable.Client
}

func NewResolvable(airtableClient airtable.Client) gqlcommon.Resolvable {
	return privateIntensity{airtableClient}
}

func (i privateIntensity) GetAll() graphql.FieldResolveFn {
	return func(p graphql.ResolveParams) (interface{}, error) {
		var result results
		err := i.Client.GetAll(p.Context, airtable.Intensity, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

func (i privateIntensity) Get() graphql.FieldResolveFn {
	return func(p graphql.ResolveParams) (interface{}, error) {
		id, err := gqlcommon.GetId(p)
		if err != nil {
			return nil, err
		}

		var result intensityZone
		err = i.Client.Get(p.Context, airtable.Intensity, id, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

func (i privateIntensity) GetByIds(ctx context.Context, ids []string) (interface{}, error) {
	return nil, errors.New("not implemented")
}

func (i privateIntensity) GetById(ctx context.Context, id string) (interface{}, error) {
	return nil, errors.New("not implemented")
}

type results []intensityZone

func (res *results) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord intensityZone
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (res *intensityZone) MapAirtableRecord(record airtable.AirtableRecord) error {
	var fields fields
	err := json.Unmarshal(record.Fields, &fields)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}

	*res = intensityZone{
		Id:            record.Id,
		Name:          fields.Name,
		Description:   fields.Description,
		IntensityType: fields.IntensityType,
	}

	return nil
}
