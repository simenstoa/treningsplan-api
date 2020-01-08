package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/resolvables/days"
	"goapi/resolvables/intensity-zones"
	"goapi/resolvables/plans"
	"goapi/resolvables/profiles"
	"goapi/resolvables/records"
	"goapi/resolvables/weeks"
	workout_intensities "goapi/resolvables/workout-intensities"
	"goapi/resolvables/workouts"
)

func InitSchema(resolvableIntensityZones intensityzones.Resolvable, resolvableWorkout workouts.Resolvable, resolvableDay days.Resolvable, resolvableWeek weeks.Resolvable, resolvablePlan plans.Resolvable, resolvableWorkoutIntensities workout_intensities.Resolvable,
	resolvableProfile profiles.Resolvable,
	resolvableRecord records.Resolvable) (graphql.Schema, error) {
	workoutType := workoutType(resolvableWorkoutIntensities)
	dayType := dayType(resolvableWorkout, workoutType)
	weekType := weekType(resolvableDay, dayType)
	planType := planType(resolvableWeek, weekType)
	recordType := recordType()
	profileType := profileType(resolvableRecord, recordType)

	var queryType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "Query",
			Fields: graphql.Fields{
				"intensityZones": intensityZonesField(resolvableIntensityZones),
				"workouts":       workoutsField(resolvableWorkout, workoutType),
				"workout":        workoutField(resolvableWorkout, workoutType),
				"plans":          plansField(resolvablePlan, planType),
				"plan":           planField(resolvablePlan, planType),
				"profile":        profileField(resolvableProfile, profileType),
			},
		})

	return graphql.NewSchema(
		graphql.SchemaConfig{
			Query: queryType,
		},
	)
}
