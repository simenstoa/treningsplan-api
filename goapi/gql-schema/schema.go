package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/intensity"
)

func InitSchema(resolvableIntensity intensity.Intensity) (graphql.Schema, error) {
	var queryType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "Query",
			Fields: graphql.Fields{
				"intensityZones": InitIntensityZones(resolvableIntensity.Resolver()),
			},
		})

	return graphql.NewSchema(
		graphql.SchemaConfig{
			Query: queryType,
		},
	)
}
