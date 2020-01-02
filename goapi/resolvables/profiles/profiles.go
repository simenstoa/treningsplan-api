package profiles

import (
	"context"
	"encoding/json"
	"goapi/airtable"
	"log"
)

type Profile struct {
	Id        string `json:"id"`
	Firstname string `json:"firstname,omitempty"`
	Surname   string `json:"surname,omitempty"`
	Vdot      int    `json:"vdot,omitempty"`
}

type Profiles []Profile

type privateProfile struct {
	airtable.Client
}

type Resolvable interface {
	GetAll(ctx context.Context) (Profiles, error)
	Get(ctx context.Context, id string) (Profile, error)
}

func NewResolvable(airtableClient airtable.Client) Resolvable {
	return privateProfile{airtableClient}
}

func (i privateProfile) GetAll(ctx context.Context) (Profiles, error) {
	var plans Profiles
	err := i.Client.GetAll(ctx, airtable.Profile, &plans)
	if err != nil {
		return Profiles{}, err
	}
	return plans, nil
}

func (i privateProfile) Get(ctx context.Context, id string) (Profile, error) {
	var plans Profile
	err := i.Client.Get(ctx, airtable.Profile, id, &plans)
	if err != nil {
		return Profile{}, err
	}
	return plans, nil
}

func (res *Profiles) MapAirtableResult(result airtable.AirtableResult) error {
	for _, record := range result.Records {
		var mappedRecord Profile
		err := mappedRecord.MapAirtableRecord(record)
		if err != nil {
			return err
		}

		*res = append(*res, mappedRecord)
	}
	return nil
}

func (res *Profile) MapAirtableRecord(record airtable.AirtableRecord) error {
	err := json.Unmarshal(record.Fields, res)
	if err != nil {
		log.Println("could not unmarshall record")
		return err
	}
	return nil
}
