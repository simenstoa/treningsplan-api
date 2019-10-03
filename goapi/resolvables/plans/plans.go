package plans

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type Plan struct {
	Id          string   `json:"id"`
	Name        string   `json:"name,omitempty"`
	Description string   `json:"description,omitempty"`
	Weeks       []string `json:"weeks,omitempty"`
}

type Plans []Plan

type privatePlan struct {
	airtable.Client
}

type Resolvable interface {
	GetAll(ctx context.Context) (Plans, error)
	Get(ctx context.Context, id string) (Plan, error)
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return privatePlan{airtableClient}
}

func (i privatePlan) GetAll(ctx context.Context) (Plans, error) {
	var plans Plans
	err := i.Client.GetAll(ctx, airtable.Plan, &plans)
	if err != nil {
		return Plans{}, err
	}
	return plans, nil
}

func (i privatePlan) Get(ctx context.Context, id string) (Plan, error) {
	var plans Plan
	err := i.Client.Get(ctx, airtable.Plan, id, &plans)
	if err != nil {
		return Plan{}, err
	}
	return plans, nil
}

func (res *Plans) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord Plan
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (res *Plan) MapAirtableRecord(record airtable.AirtableRecord) error {
	err := json.Unmarshal(record.Fields, res)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}
	return nil
}
