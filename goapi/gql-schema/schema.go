package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/resolvables/days"
	"goapi/resolvables/intensity-zones"
	"goapi/resolvables/plans"
	"goapi/resolvables/weeks"
	"goapi/resolvables/workouts"
)

func InitSchema(resolvableIntensityZones intensityzones.Resolvable, resolvableWorkout workouts.Resolvable, resolvableDay days.Resolvable, resolvableWeek weeks.Resolvable, resolvablePlan plans.Resolvable) (graphql.Schema, error) {
	workoutType := workoutType()
	dayType := dayType(workoutType, resolvableWorkout)
	weekType := weekType(dayType, resolvableDay)
	planType := planType(weekType, resolvableWeek)

	var queryType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "Query",
			Fields: graphql.Fields{
				"intensityZones": intensityZonesField(resolvableIntensityZones),
				"workouts":       workoutsField(resolvableWorkout, workoutType),
				"workout":        workoutField(resolvableWorkout, workoutType),
				"plans":          plansField(resolvablePlan, planType),
				"plan":           planField(resolvablePlan, planType),
			},
		})

	return graphql.NewSchema(
		graphql.SchemaConfig{
			Query: queryType,
		},
	)
}
