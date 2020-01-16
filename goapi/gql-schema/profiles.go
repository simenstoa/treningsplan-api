package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/database"
	"goapi/gql-common"
)

func profileFields(dbClient database.Client, recordType *graphql.Object) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"firstname": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"lastname": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"vdot": &graphql.Field{
			Type: graphql.NewNonNull(graphql.Int),
		},
		"records": &graphql.Field{
			Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(recordType))),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				return dbClient.GetRecords(p.Context, p.Source.(database.Profile).Id)
			},
		},
	}
}

func profileType(dbClient database.Client, recordType *graphql.Object) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Profile",
			Fields: profileFields(dbClient, recordType),
		},
	)
}

func profilesField(dbClient database.Client, profileType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: graphql.NewNonNull(graphql.NewList(profileType)),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return dbClient.GetProfiles(p.Context)
		},
	}
}

func profileField(dbClient database.Client, profileType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: profileType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return dbClient.GetProfile(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:         graphql.NewNonNull(graphql.String),
				Description:  "The id of the profile",
			},
		},
	}
}
