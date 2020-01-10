package intensityzones

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"goapi/database"
	"log"
)

type IntensityZone struct {
	Id          string  `json:"id"`
	Name        string  `json:"name,omitempty"`
	Description string  `json:"description,omitempty"`
	Coefficient float64 `json:"coefficient,omitempty"`
}

type IntensityZones []IntensityZone

type Resolvable interface {
	GetAll(ctx context.Context) (IntensityZones, error)
	Get(ctx context.Context, id string) (IntensityZone, error)
}

type privateIntensity struct {
	airtableClient airtable.Client
	databaseClient database.Client
}

func NewResolvable(airtableClient airtable.Client, databaseClient database.Client) Resolvable {
	return privateIntensity{airtableClient, databaseClient}
}

func (i privateIntensity) GetAll(ctx context.Context) (IntensityZones, error) {
	var result IntensityZones
	intensities, err := i.databaseClient.GetIntensities(ctx)
	if err != nil {
		return IntensityZones{}, err
	}
	for _, intensity := range intensities {
		result = append(result, IntensityZone{
			Id:          intensity.Id,
			Name:        intensity.Name,
			Description: intensity.Description,
			Coefficient: intensity.Coefficient,
		})
	}
	return result, nil
}

func (i privateIntensity) Get(ctx context.Context, id string) (IntensityZone, error) {
	var result IntensityZone
	err := i.airtableClient.Get(ctx, airtable.Intensity, id, &result)
	if err != nil {
		return IntensityZone{}, err
	}
	return result, nil
}

func (res *IntensityZones) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var intensityZones IntensityZone
		err := intensityZones.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, intensityZones)
	}
	return nil
}

func (res *IntensityZone) MapAirtableRecord(record airtable.AirtableRecord) error {
	err := json.Unmarshal(record.Fields, res)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}
	return nil
}
