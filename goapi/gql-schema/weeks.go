package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/gql-common"
	"goapi/resolvables/days"
	"goapi/resolvables/weeks"
)

func weekFields(dayType *graphql.Object, resolvableDays days.Resolvable) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.String,
		},
		"order": &graphql.Field{
			Type: graphql.Int,
		},
		"days": &graphql.Field{
			Type: graphql.NewList(dayType),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				return resolvableDays.GetByParentId(p.Context, p.Source.(weeks.Week).Id)
			},
		},
		"distance": &graphql.Field{
			Type: graphql.Int,
		},
	}
}

func weekType(dayType *graphql.Object, resolvableDays days.Resolvable) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Week",
			Fields: weekFields(dayType, resolvableDays),
		},
	)
}

func weeksField(resolvableWeek weeks.Resolvable, weekType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: graphql.NewList(weekType),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return resolvableWeek.GetAll(p.Context)
		},
	}
}

func weekField(resolvableWeek weeks.Resolvable, weekType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: weekType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return resolvableWeek.Get(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:         graphql.NewNonNull(graphql.String),
				Description:  "The id of the week",
			},
		},
	}
}
