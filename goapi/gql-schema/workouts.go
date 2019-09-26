package gqlschema

import (
	"errors"
	"github.com/graphql-go/graphql"
	"goapi/bouts"
	"goapi/gql-common"
	"goapi/intensity-zones"
	"goapi/workout-bouts"
	"goapi/workouts"
)

func boutType(resolvableIntensityZones intensityzones.Resolvable) *graphql.Object {
	return graphql.NewObject(graphql.ObjectConfig{
		Name: "Bout",
		Fields: graphql.Fields{
			"id": &graphql.Field{
				Type: graphql.String,
			},
			"order": &graphql.Field{
				Type: graphql.Int,
			},
			"name": &graphql.Field{
				Type: graphql.String,
			},
			"duration": &graphql.Field{
				Type: graphql.Int,
			},
			"length": &graphql.Field{
				Type: graphql.Int,
			},
			"type": &graphql.Field{
				Type: graphql.String,
			},
			"intensity": &graphql.Field{
				Type: intensityZoneType,
				Resolve: func(p graphql.ResolveParams) (interface{}, error) {
					intensities := p.Source.(boutGqlType).Intensity
					if len(intensities) != 1 {
						return nil, nil
					}
					return resolvableIntensityZones.Get(p.Context, intensities[0])
				},
			},
		},
	})
}

type boutGqlType struct {
	Id        string
	Order     int
	Name      string
	Duration  int
	Length    int
	Type      string
	Intensity []string
}

func workoutFields(resolvableWorkoutBouts workoutbouts.Resolvable, resolvableBouts bouts.Resolvable, boutType *graphql.Object) graphql.Fields {
	return graphql.Fields{
		"id": &graphql.Field{
			Type: graphql.String,
		},
		"name": &graphql.Field{
			Type: graphql.String,
		},
		"purpose": &graphql.Field{
			Type: graphql.String,
		},
		"description": &graphql.Field{
			Type: graphql.String,
		},
		"bouts": &graphql.Field{
			Type: graphql.NewList(boutType),
			Resolve: func(p graphql.ResolveParams) (interface{}, error) {
				parentId := p.Source.(workouts.Workout).Id
				workoutBouts, err := resolvableWorkoutBouts.GetByParentId(p.Context, parentId)
				if err != nil {
					return nil, err
				}
				var boutIds []string
				for _, workoutBout := range workoutBouts {
					if len(workoutBout.Bout) != 1 {
						return nil, errors.New("invalid workout bouts")
					}
					id := workoutBout.Bout[0]
					boutIds = append(boutIds, id)
				}
				bts, err := resolvableBouts.GetByIds(p.Context, boutIds)
				if err != nil {
					return nil, err
				}
				btsMap := make(map[string]bouts.Bout)
				for _, bt := range bts {
					btsMap[bt.Id] = bt
				}
				var gqlBouts []boutGqlType
				for _, wbt := range workoutBouts {
					bt := btsMap[wbt.Bout[0]]

					gqlBouts = append(gqlBouts, boutGqlType{
						Id:        bt.Id,
						Order:     wbt.Order,
						Name:      bt.Name,
						Length:    bt.Length,
						Duration:  bt.Duration,
						Type:      bt.Type,
						Intensity: bt.Intensity,
					})
				}

				return gqlBouts, nil
			},
		},
	}
}

func workoutType(resolvableWorkoutBouts workoutbouts.Resolvable, resolvableBouts bouts.Resolvable, boutType *graphql.Object) *graphql.Object {
	return graphql.NewObject(
		graphql.ObjectConfig{
			Name:   "Workout",
			Fields: workoutFields(resolvableWorkoutBouts, resolvableBouts, boutType),
		},
	)
}

func workoutsField(resolvableWorkout workouts.Resolvable, workoutType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type:    graphql.NewList(workoutType),
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			return resolvableWorkout.GetAll(p.Context)
		},
	}
}

func workoutField(resolvableWorkout workouts.Resolvable, workoutType *graphql.Object) *graphql.Field {
	return &graphql.Field{
		Type: workoutType,
		Resolve: func(p graphql.ResolveParams) (interface{}, error) {
			id, err := gqlcommon.GetId(p)
			if err != nil {
				return nil, err
			}
			return resolvableWorkout.Get(p.Context, id)
		},
		Args: map[string]*graphql.ArgumentConfig{
			"id": {
				Type:         graphql.String,
				DefaultValue: nil,
				Description:  "The id of the workout",
			},
		},
	}
}
