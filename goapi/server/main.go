package main

import (
	"context"
	"goapi/airtable"
	"goapi/bouts"
	"goapi/config"
	gqlschema "goapi/gql-schema"
	"goapi/intensity-zones"
	"goapi/workouts"
	workoutbouts "goapi/workout-bouts"
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
	resolvableWorkoutBouts := workoutbouts.NewResolvable(airtableClient)
	resolvableBout := bouts.NewResolvable(airtableClient)

	schema, err := gqlschema.InitSchema(resolvableIntensity, resolvableWorkout, resolvableWorkoutBouts, resolvableBout)
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
