package airtable

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

const (
	baseUrl = "https://api.airtable.com/v0/appKpRGYhVdY3IspT/"
)

type Table string

const (
	Intensity    Table = "Intensity"
	Workout      Table = "Workout"
	WorkoutBouts Table = "WorkoutBouts"
	Bout         Table = "Bout"
)

type AirtableResult struct {
	Records []AirtableRecord `json:"records"`
}

type AirtableRecord struct {
	Id     string          `json:"id"`
	Fields json.RawMessage `json:"fields"`
}

type Client interface {
	GetAll(ctx context.Context, table Table, mapper airtableResultMapper) error
	Get(ctx context.Context, table Table, id string, mapper airtableRecordMapper) error
	GetByIds(ctx context.Context, table Table, parentTable Table, parentId string, result airtableResultMapper) error
}

type airtableResultMapper interface {
	MapAirtableResult(result AirtableResult) error
}

type airtableRecordMapper interface {
	MapAirtableRecord(record AirtableRecord) error
}

type airTableClient struct {
	client    *http.Client
	apiSecret string
}

func NewClient(ctx context.Context, apiSecret string) (Client, error) {
	return &airTableClient{
		client: &http.Client{
			Timeout: 3 * time.Second,
		},
		apiSecret: apiSecret,
	}, nil
}

func (c *airTableClient) GetAll(ctx context.Context, table Table, result airtableResultMapper) error {
	req, err := http.NewRequest(http.MethodGet, baseUrl+string(table), nil)
	if err != nil {
		log.Println("could not create request")
		return err
	}

	body, err := c.fetchResult(ctx, req)
	if err != nil {
		return err
	}

	var airtableResult AirtableResult
	err = json.Unmarshal(body, &airtableResult)
	if err != nil {
		log.Println("error decoding result")
		return err
	}

	err = result.MapAirtableResult(airtableResult)
	if err != nil {
		log.Println("error mapping airtable result")
		return err
	}
	return nil
}

func (c *airTableClient) Get(ctx context.Context, table Table, id string, result airtableRecordMapper) error {
	req, err := http.NewRequest(http.MethodGet, baseUrl+string(table)+"/"+id, nil)
	if err != nil {
		log.Println("could not create request")
		return err
	}

	body, err := c.fetchResult(ctx, req)
	if err != nil {
		return err
	}

	var airtableRecord AirtableRecord
	err = json.Unmarshal(body, &airtableRecord)
	if err != nil {
		log.Println("error decoding result")
		return err
	}

	err = result.MapAirtableRecord(airtableRecord)
	if err != nil {
		log.Println("error mapping airtable result")
		return err
	}
	return nil
}

func (c *airTableClient) GetByIds(ctx context.Context, table Table, parentTable Table, parentId string, result airtableResultMapper) error {
	req, err := http.NewRequest(http.MethodGet, baseUrl+string(table)+"?filterByFormula=\""+string(parentTable)+"="+parentId+"\"", nil)
	if err != nil {
		log.Println("could not create request")
		return err
	}

	body, err := c.fetchResult(ctx, req)
	if err != nil {
		return err
	}

	var airtableResult AirtableResult
	err = json.Unmarshal(body, &airtableResult)
	if err != nil {
		log.Println("error decoding result")
		return err
	}

	err = result.MapAirtableResult(airtableResult)
	if err != nil {
		log.Println("error mapping airtable result")
		return err
	}
	return nil
}

func (c *airTableClient) fetchResult(ctx context.Context, req *http.Request) ([]byte, error) {
	req.Header.Add("Authorization", "Bearer "+c.apiSecret)
	req = req.WithContext(ctx)
	resp, err := c.client.Do(req)
	if err != nil {
		log.Println("error calling airtable")
		return nil, err
	}
	defer func() {
		err := resp.Body.Close()
		if err != nil {
			log.Println("error closing body")
		}
	}()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Println("error reading body")
		return nil, err
	}
	return body, nil
}
