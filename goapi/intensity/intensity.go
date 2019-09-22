package intensity

import (
	"encoding/json"
	"github.com/graphql-go/graphql"
	"goapi/airtable"
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

type Intensity interface {
	Resolver() func(p graphql.ResolveParams) (interface{}, error)
}

type privateIntensity struct {
	airtable.Client
}

func New(airtableClient airtable.Client) Intensity {
	return privateIntensity{airtableClient}
}

func (i privateIntensity) Resolver() func(p graphql.ResolveParams) (interface{}, error) {
	return func(p graphql.ResolveParams) (interface{}, error) {
		var result zones
		err := i.Client.Get(p.Context, airtable.Intensity, &result)
		if err != nil {
			return nil, err
		}
		return result, nil
	}
}

type zones []intensityZone

func (z *zones) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var fields fields
		err := json.Unmarshal(record.Fields, &fields)
		if err != nil {
			log.Println("could not unmarshall intensity zone")
			return err
		}

		*z = append(*z, intensityZone{
			Id:     record.Id,
			Name: fields.Name,
			Description: fields.Description,
			IntensityType: fields.IntensityType,
		})
	}
	return nil
}