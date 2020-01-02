package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/gql-common"
	"goapi/resolvables/profiles"
)

func profileFields() graphql.Fields {
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
	}
}

func profileType() *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Profile",
			Fields: profileFields(),
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
