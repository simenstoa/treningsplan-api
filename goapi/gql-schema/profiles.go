package gqlschema

import (
	"errors"
	"github.com/graphql-go/graphql"
	"goapi/appcontext"
	"goapi/database"
	"goapi/gql-common"
	"goapi/logger"
	"goapi/models"
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
				return dbClient.GetRecords(p.Context, p.Source.(models.Profile).Id)
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

func meField(profileType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: profileType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			log := logger.FromContext(p.Context)
			authenticated, err := appcontext.UserAuthenticated(p.Context)
			if err != nil || !authenticated {
				log.Error("The user must be logged in to use this query")
				return nil, errors.New("the user must be logged in to use this query")
			}
			profile, err := appcontext.Profile(p.Context)
			if err != nil || !authenticated {
				log.Error("Profile expected to be on Context, but was not found.")
				return nil, errors.New("unexpected error")
			}

			return profile, nil
		},
	}
}