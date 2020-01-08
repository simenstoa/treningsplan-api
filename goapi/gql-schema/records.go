package gqlschema

import (
	"github.com/graphql-go/graphql"
)

func recordFields() graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"race": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"duration": &graphql.Field{
			Type: graphql.NewNonNull(graphql.Int),
		},
	}
}

func recordType() *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Record",
			Fields: recordFields(),
		},
	)
}
