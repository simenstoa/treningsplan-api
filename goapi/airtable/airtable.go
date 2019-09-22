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
	Intensity Table = "Intensity"
)

type AirtableResult struct {
	Records []airtableRecord `json:"records"`
}

type airtableRecord struct {
	Id     string          `json:"id"`
	Fields json.RawMessage `json:"fields"`
}

type Client interface {
	Get(ctx context.Context, table Table, result airtableCommon) error
}

type airtableCommon interface {
	MapAirtableResult(result AirtableResult) error
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

func (c *airTableClient) Get(ctx context.Context, table Table, result airtableCommon) error {
	req, err := http.NewRequest(http.MethodGet, baseUrl+string(table), nil)
	if err != nil {
		log.Println("could not create request")
		return err
	}

	req.Header.Add("Authorization", "Bearer "+c.apiSecret)
	req = req.WithContext(ctx)

	resp, err := c.client.Do(req)
	if err != nil {
		log.Println("error calling airtable")
		return err
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
		return err
	}

	var airtableResult AirtableResult
	err = json.Unmarshal(body, &airtableResult)
	if err != nil {
		log.Println("error decoding result")
		return err
	}

	result.MapAirtableResult(airtableResult)

	return nil
}
