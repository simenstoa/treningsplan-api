package days

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type Day struct {
	Id       string   `json:"id"`
	Day      int      `json:"day,omitempty"`
	Workouts []string `json:"workouts,omitempty"`
	Distance int      `json:"distance,omitempty"`
}

type Days []Day

type privateDays struct {
	airtable.Client
}

type Resolvable interface {
	GetByParentId(ctx context.Context, parentId string) (Days, error)
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return privateDays{airtableClient}
}

func (i privateDays) GetByParentId(ctx context.Context, parentId string) (Days, error) {
	var days Days
	err := i.Client.GetByParentId(ctx, airtable.Day, airtable.Week, parentId, &days)
	if err != nil {
		return nil, err
	}
	return days, nil
}

func (res *Days) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord Day
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (day *Day) MapAirtableRecord(record airtable.AirtableRecord) error {
	err := json.Unmarshal(record.Fields, day)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}

	return nil
}
