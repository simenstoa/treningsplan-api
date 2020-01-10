package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/resolvables/intensity-zones"
)

var intensityType = graphql.NewObject(
	graphql.ObjectConfig{
		Name:   "Intensity",
		Fields: intensityZoneFields,
	},
)

var intensityZoneFields = graphql.Fields{
	"id": &graphql.Field{
		Type: graphql.NewNonNull(graphql.String),
	},
	"name": &graphql.Field{
		Type: graphql.NewNonNull(graphql.String),
	},
	"description": &graphql.Field{
		Type: graphql.String,
	},
	"coefficient": &graphql.Field{
		Type: graphql.NewNonNull(graphql.Float),
	},
}

func intensityZonesField(resolvableIntensityZones intensityzones.Resolvable) *graphql.Field {
	return &graphql.Field{
		Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(intensityType))),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return resolvableIntensityZones.GetAll(p.Context)
		},
	}
}
