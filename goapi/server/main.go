package main

import (
	"context"
	"goapi/airtable"
	"goapi/config"
	gqlschema "goapi/gql-schema"
	"goapi/resolvables/days"
	"goapi/resolvables/intensity-zones"
	"goapi/resolvables/plans"
	"goapi/resolvables/weeks"
	"goapi/resolvables/workouts"
	"log"
	"net/http"

	"github.com/graphql-go/handler"
)

func main() {
	cfg := config.FromEnv()

	ctx := context.Background()
	ctx = context.WithValue(ctx, "is_startup", true)

	airtableClient, err := airtable.NewClient(ctx, cfg.AirtableSecret)
	if err != nil {
		log.Fatalf("failed to create airtable client, error: %v", err)
	}

	resolvableIntensity := intensityzones.NewResolvable(airtableClient)
	resolvableWorkout := workouts.NewResolvable(airtableClient)
	resolvableDay := days.NewResolvable(airtableClient)
	resolvableWeek := weeks.NewResolvable(airtableClient)
	resolvablePlan := plans.NewResolvable(airtableClient)

	schema, err := gqlschema.InitSchema(resolvableIntensity, resolvableWorkout, resolvableDay, resolvableWeek, resolvablePlan)
	if err != nil {
		log.Fatalf("failed to create new schema, error: %v", err)
	}

	h := handler.New(&handler.Config{
		Schema: &schema,
		Pretty: true,
		GraphiQL: false,
		Playground: true,
	})

	http.Handle("/", h)
	err = http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("failed to create new schema, error: %v", err)
	}
}
