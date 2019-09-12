package main

import (
	gqlschema "goapi/gql-schema"
	"log"
	"net/http"

	"github.com/graphql-go/handler"
)

func main() {
	var schema, err = gqlschema.InitSchema()
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
