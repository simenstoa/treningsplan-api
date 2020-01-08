package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/gql-common"
	"goapi/resolvables/profiles"
	"goapi/resolvables/records"
)

func profileFields(resolvableRecord records.Resolvable, recordType *graphql.Object) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"firstname": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"surname": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"vdot": &graphql.Field{
			Type: graphql.NewNonNull(graphql.Int),
		},
		"records": &graphql.Field{
			Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(recordType))),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				return resolvableRecord.GetByParentId(p.Context, p.Source.(profiles.Profile).Id)
			},
		},
	}
}

func profileType(resolvableRecord records.Resolvable, recordType *graphql.Object) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Profile",
			Fields: profileFields(resolvableRecord, recordType),
		},
	)
}

func profileField(resolvableProfiles profiles.Resolvable, profileType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: profileType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return resolvableProfiles.Get(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:         graphql.NewNonNull(graphql.String),
				Description:  "The id of the profile",
			},
		},
	}
}
