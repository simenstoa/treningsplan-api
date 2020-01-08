package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/gql-common"
	"goapi/resolvables/plans"
	"goapi/resolvables/weeks"
)

func planFields(resolvableWeeks weeks.Resolvable, weekType *graphql.Object) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"name": &graphql.Field{
			Type: graphql.NewNonNull(graphql.String),
		},
		"description": &graphql.Field{
			Type: graphql.String,
		},
		"weeks": &graphql.Field{
			Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(weekType))),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				return resolvableWeeks.GetByParentId(p.Context, p.Source.(plans.Plan).Id)
			},
		},
	}
}

func planType(resolvableWeeks weeks.Resolvable, weekType *graphql.Object) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Plan",
			Fields: planFields(resolvableWeeks, weekType),
		},
	)
}

func plansField(resolvablePlan plans.Resolvable, planType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type:   graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(planType))),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return resolvablePlan.GetAll(p.Context)
		},
	}
}

func planField(resolvablePlan plans.Resolvable, planType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: planType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return resolvablePlan.Get(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:         graphql.NewNonNull(graphql.String),
				Description:  "The id of the plan",
			},
		},
	}
}
