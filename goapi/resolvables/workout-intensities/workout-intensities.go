package workout_intensities

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type WorkoutIntensity struct {
	Id          string    `json:"id"`
	Distance    int       `json:"distance,omitempty"`
	Coefficient float64 `json:"coefficient,omitempty"`
	Metric      string    `json:"metric,omitempty"`
	Intensity   string  `json:"intensity,omitempty"`
	Name        string  `json:"name,omitempty"`
	Description string  `json:"description,omitempty"`
}

type airtableWorkoutIntensity struct {
	Id          string    `json:"id"`
	Distance    int       `json:"distance,omitempty"`
	Coefficient []float64 `json:"coefficient,omitempty"`
	Metric      string    `json:"metric,omitempty"`
	Intensity   []string  `json:"intensity,omitempty"`
	Name        []string  `json:"name,omitempty"`
	Description []string  `json:"description,omitempty"`
}

type WorkoutIntensities []WorkoutIntensity

type privateDays struct {
	airtable.Client
}

type Resolvable interface {
	GetByParentId(ctx context.Context, parentId string) (WorkoutIntensities, error)
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return privateDays{airtableClient}
}

func (i privateDays) GetByParentId(ctx context.Context, parentId string) (WorkoutIntensities, error) {
	var workoutIntensities WorkoutIntensities
	err := i.Client.GetByParentId(ctx, airtable.WorkoutIntensity, airtable.Workout, parentId, &workoutIntensities)
	if err != nil {
		return nil, err
	}
	return workoutIntensities, nil
}

func (res *WorkoutIntensities) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord WorkoutIntensity
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (day *WorkoutIntensity) MapAirtableRecord(record airtable.AirtableRecord) error {
	var airtableWorkoutIntensity airtableWorkoutIntensity
	err := json.Unmarshal(record.Fields, &airtableWorkoutIntensity)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}

	day.Id = airtableWorkoutIntensity.Id
	day.Metric = airtableWorkoutIntensity.Metric
	day.Distance = airtableWorkoutIntensity.Distance
	day.Coefficient = airtableWorkoutIntensity.Coefficient[0]
	day.Intensity = airtableWorkoutIntensity.Intensity[0]
	day.Description = airtableWorkoutIntensity.Description[0]
	day.Name = airtableWorkoutIntensity.Name[0]

	return nil
}
