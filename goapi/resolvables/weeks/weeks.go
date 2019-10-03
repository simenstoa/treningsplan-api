package weeks

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type Week struct {
	Id       string   `json:"id"`
	Order    int      `json:"order,omitempty"`
	Distance int      `json:"distance,omitempty"`
	Days     []string `json:"days,omitempty"`
}

type Weeks []Week

type client struct {
	airtable.Client
}

type Resolvable interface {
	GetAll(ctx context.Context) (Weeks, error)
	Get(ctx context.Context, id string) (Week, error)
	GetByParentId(ctx context.Context, parentId string) (Weeks, error)
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return client{airtableClient}
}

func (cli client) GetAll(ctx context.Context) (Weeks, error) {
	var weeks Weeks
	err := cli.Client.GetAll(ctx, airtable.Week, &weeks)
	if err != nil {
		return Weeks{}, err
	}
	return weeks, nil
}

func (cli client) Get(ctx context.Context, id string) (Week, error) {
	var result Week
	err := cli.Client.Get(ctx, airtable.Week, id, &result)
	if err != nil {
		return Week{}, err
	}
	return result, nil
}

func (cli client) GetByParentId(ctx context.Context, parentId string) (Weeks, error) {
	var weeks Weeks
	err := cli.Client.GetByParentId(ctx, airtable.Week, airtable.Plan, parentId, &weeks)
	if err != nil {
		return Weeks{}, err
	}
	return weeks, nil
}

func (res *Weeks) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord Week
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (res *Week) MapAirtableRecord(record airtable.AirtableRecord) error {
	err := json.Unmarshal(record.Fields, res)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}
	return nil
}
