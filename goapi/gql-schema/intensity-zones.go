package gqlschema

import "github.com/graphql-go/graphql"

type intensityZone struct {
	Id            string `json:"id"`
	Title         string `json:"title"`
	ShortTitle    string `json:"shortTitle"`
	Description   string `json:"description"`
	IntensityType string `json:"type"`
}

var intensityZones = []intensityZone{
	{Id: "1", Title: "Easy runs", IntensityType: "E", Description: "65%-79% of max hearth rate, or 59%-74% of VDOT."},
	{Id: "2", Title: "Marathon-pace runs", IntensityType: "M", Description: "80%-89% of max hearth rate, or 75%-84% of VDOT."},
	{Id: "3", Title: "(Lactate) Threshold running", IntensityType: "T", Description: "88%-92% of max hearth rate, or 83%-88% of VDOT."},
}

var intensityZoneType = graphql.NewObject(
	graphql.ObjectConfig{
		Name: "IntensityZone",
		Fields: graphql.Fields{
			"id": &graphql.Field{
				Type: graphql.String,
			},
			"title": &graphql.Field{
				Type: graphql.String,
			},
			"intensityType": &graphql.Field{
				Type: graphql.String,
			},
			"description": &graphql.Field{
				Type: graphql.String,
			},
		},
	},
)

var IntensityZones = &graphql.Field{
	Type: graphql.NewList(intensityZoneType),
	Resolve: func(p graphql.ResolveParams) (interface{}, error) {
		return intensityZones, nil
	},
}
