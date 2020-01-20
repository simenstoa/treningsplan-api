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

var (
	metric = graphql.NewNonNull(graphql.NewEnum(graphql.EnumConfig{
		Name: "MetricV2",
		Values: graphql.EnumValueConfigMap{
			"METER": &graphql.EnumValueConfig{
				Value: "meter",
			},
			"SECOND": &graphql.EnumValueConfig{
				Value: "second",
			},
		},
	}))

	partType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "WorkoutPart",
			Fields: graphql.Fields{
				"order": &graphql.Field{
					Type: graphql.NewNonNull(graphql.Int),
				},
				"distance": &graphql.Field{
					Type: graphql.NewNonNull(graphql.Int),
				},
				"metric": &graphql.Field{
					Type: metric,
				},
				"intensity": &graphql.Field{
					Type: graphql.NewNonNull(intensityType),
				},
			}})
)

func workoutV2Fields(dbClient database.Client, profileType *graphql.Object) graphql.Fields {
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
		"parts": &graphql.Field{
			Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(partType))),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				return dbClient.GetWorkoutPartsForWorkout(p.Context, p.Source.(models.Workout).Id)
			},
		},
		"createdBy": &graphql.Field{
			Type: graphql.NewNonNull(profileType),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				return dbClient.GetProfile(p.Context, p.Source.(models.Workout).CreatedBy)
			},
		},
	}
}

func workoutV2Type(dbClient database.Client, profileType *graphql.Object) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "WorkoutV2",
			Fields: workoutV2Fields(dbClient, profileType),
		},
	)
}

func workoutV2sField(dbClient database.Client, workoutType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: graphql.NewNonNull(graphql.NewList(graphql.NewNonNull(workoutType))),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return dbClient.GetWorkouts(p.Context)
		},
	}
}

func workoutV2Field(dbClient database.Client, workoutType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: workoutType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return dbClient.GetWorkout(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:        graphql.NewNonNull(graphql.String),
				Description: "The id of the workout",
			},
		},
	}
}

func createWorkoutV2Mutation(dbClient database.Client, workoutType *graphql.Object) *graphql.Field {
	name := "name"
	description := "description"

	return &graphql.Field{
		Type: workoutType,
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

			text, err := gqlcommon.GetStringArgument(p, name)
			if err != nil {
				return nil, err
			}
			description, err := gqlcommon.GetStringArgument(p, description)
			if err != nil {
				description = ""
			}

			return dbClient.CreateWorkout(p.Context, text, description, profile.Id)
		},
		Args: graphql.FieldConfigArgument{
			name: &graphql.ArgumentConfig{
				Type: graphql.NewNonNull(graphql.String),
			},
			description: &graphql.ArgumentConfig{
				Type: graphql.String,
			},
		},
	}
}

func addWorkoutPartMutation(dbClient database.Client, workoutType *graphql.Object) *graphql.Field {
	workoutId := "workoutId"
	order := "order"
	distance := "distance"
	metric := "metric"
	intensityId := "intensityId"

	return &graphql.Field{
		Type: workoutType,
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

			workoutId, err := gqlcommon.GetStringArgument(p, workoutId)
			if err != nil {
				return nil, err
			}
			order, err := gqlcommon.GetIntArgument(p, order)
			if err != nil {
				return nil, err
			}
			distance, err := gqlcommon.GetIntArgument(p, distance)
			if err != nil {
				distance = 0
			}
			metric, err := gqlcommon.GetStringArgument(p, metric)
			if err != nil {
				metric = "meter"
			}
			intensityId, err := gqlcommon.GetStringArgument(p, intensityId)
			if err != nil {
				return nil, err
			}

			return dbClient.AddWorkoutPart(p.Context, workoutId, order, distance, metric, intensityId, profile.Id)
		},
		Args: graphql.FieldConfigArgument{
			workoutId: &graphql.ArgumentConfig{
				Type: graphql.NewNonNull(graphql.String),
			},
			order: &graphql.ArgumentConfig{
				Type: graphql.NewNonNull(graphql.Int),
			},
			distance: &graphql.ArgumentConfig{
				Type: graphql.NewNonNull(graphql.Int),
			},
			metric: &graphql.ArgumentConfig{
				Type: graphql.String,
			},
			intensityId: &graphql.ArgumentConfig{
				Type: graphql.NewNonNull(graphql.String),
			},
		},
	}
}