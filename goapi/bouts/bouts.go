package bouts

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type Bout struct {
	Id        string   `json:"id,omitempty"`
	Name      string   `json:"name,omitempty"`
	Duration  int      `json:"duration,omitempty"`
	Length    int      `json:"length,omitempty"`
	Type      string   `json:"type,omitempty"`
	Intensity []string `json:"intensity,omitempty"`
}

type Bouts []Bout

type Resolvable interface {
	GetByIds(ctx context.Context, ids []string) (Bouts, error)
}

type privateBout struct {
	airtable.Client
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return privateBout{airtableClient}
}

func (i privateBout) GetByIds(ctx context.Context, ids []string) (Bouts, error) {
	var bouts Bouts
	err := i.Client.GetByIds(ctx, airtable.Bout, ids, &bouts)
	if err != nil {
		return nil, err
	}
	return bouts, nil
}

func (res *Bouts) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var bout Bout
		err := bout.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, bout)
	}
	return nil
}

func (res *Bout) MapAirtableRecord(record airtable.AirtableRecord) error {
	err := json.Unmarshal(record.Fields, res)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}
	return nil
}
