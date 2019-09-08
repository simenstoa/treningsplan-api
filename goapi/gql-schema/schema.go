package gqlschema

import "github.com/graphql-go/graphql"

func InitSchema() (graphql.Schema, error) {
	var queryType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "Query",
			Fields: graphql.Fields{
				"intensityZones": IntensityZones,
			},
		})

	return graphql.NewSchema(
		graphql.SchemaConfig{
			Query: queryType,
		},
	)
}
