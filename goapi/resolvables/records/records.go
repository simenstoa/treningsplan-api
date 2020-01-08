package records

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type Record struct {
	Id       string `json:"id"`
	Race     string `json:"race,omitempty"`
	Duration int    `json:"duration,omitempty"`
}

type Records []Record

type privateDays struct {
	airtable.Client
}

type Resolvable interface {
	GetByParentId(ctx context.Context, parentId string) (Records, error)
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return privateDays{airtableClient}
}

func (i privateDays) GetByParentId(ctx context.Context, parentId string) (Records, error) {
	var records Records
	err := i.Client.GetByParentId(ctx, airtable.Record, airtable.Profile, parentId, &records)
	if err != nil {
		return nil, err
	}
	return records, nil
}

func (res *Records) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord Record
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (res *Record) MapAirtableRecord(record airtable.AirtableRecord) error {
	err := json.Unmarshal(record.Fields, res)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}
	return nil
}
