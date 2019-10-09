package main

import (
	"context"
	"github.com/sirupsen/logrus"
	"goapi/airtable"
	"goapi/appcontext"
	"goapi/appcontext/initctx"
	"goapi/config"
	gqlschema "goapi/gql-schema"
	"goapi/logger"
	"goapi/resolvables/days"
	"goapi/resolvables/intensity-zones"
	"goapi/resolvables/plans"
	"goapi/resolvables/weeks"
	"goapi/resolvables/workouts"
	"goapi/server/mw"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"github.com/graphql-go/handler"
	"github.com/rs/cors"
)

func main() {
	cfg := config.FromEnv()

	appcontext.AppName = "treningsplan-api"
	appcontext.AppPodName, _ = os.Hostname()
	appcontext.AppStartTime = time.Now().UTC()
	appcontext.LogFactory = appcontext.NewLogFactory(&cfg, logrus.Fields{
		"app":          appcontext.AppName,
		"appPodName":   appcontext.AppPodName,
		"appStartTime": appcontext.AppStartTime.Format(time.RFC3339Nano),
	})

	startupCtx, _ := initctx.InitializeContext(context.Background(), logrus.Fields{
		"is_startup": true,
	})

	log := logger.FromContext(startupCtx)

	log.Info("setting up airtable client")
	airtableClient, err := airtable.NewClient(startupCtx, cfg.AirtableSecret)
	if err != nil {
		log.WithError(err).Panic("failed to create airtable client")
	}

	resolvableIntensity := intensityzones.NewResolvable(airtableClient)
	resolvableWorkout := workouts.NewResolvable(airtableClient)
	resolvableDay := days.NewResolvable(airtableClient)
	resolvableWeek := weeks.NewResolvable(airtableClient)
	resolvablePlan := plans.NewResolvable(airtableClient)

	log.Info("setting up graphql schema")
	schema, err := gqlschema.InitSchema(resolvableIntensity, resolvableWorkout, resolvableDay, resolvableWeek, resolvablePlan)
	if err != nil {
		log.WithError(err).Panic("failed to create new schema")
	}

	c := cors.New(cors.Options{
		AllowedMethods: []string{"GET","POST", "OPTIONS"},
		AllowedOrigins: []string{"*"},
		AllowCredentials: true,
		AllowedHeaders: []string{"Content-Type","Bearer","Bearer ","content-type","Origin","Accept"},
	})

	h := handler.New(&handler.Config{
		Schema: &schema,
		Pretty: true,
		GraphiQL: false,
		Playground: true,
	})

	router := mux.NewRouter()
	router.Use(
		c.Handler,
		mw.TrackRequestStart(),
		mw.InitContext(),
		mw.TrackRequestFinish(),
	)

	router.Handle("/", h)

	err = http.ListenAndServe(":8080", router)
	if err != nil {
		log.WithError(err).Panic("failed to create new schema")
	}
}
