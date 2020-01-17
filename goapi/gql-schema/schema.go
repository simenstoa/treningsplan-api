package gqlschema

import (
	"github.com/graphql-go/graphql"
	"goapi/database"
	"goapi/resolvables/days"
	"goapi/resolvables/intensity-zones"
	"goapi/resolvables/plans"
	"goapi/resolvables/weeks"
	workout_intensities "goapi/resolvables/workout-intensities"
	"goapi/resolvables/workouts"
)

func InitSchema(
	resolvableIntensityZones intensityzones.Resolvable,
	resolvableWorkout workouts.Resolvable,
	resolvableDay days.Resolvable,
	resolvableWeek weeks.Resolvable,
	resolvablePlan plans.Resolvable,
	resolvableWorkoutIntensities workout_intensities.Resolvable,
	dbClient database.Client,
) (graphql.Schema, error) {
	workoutType := workoutType(resolvableWorkoutIntensities)
	dayType := dayType(resolvableWorkout, workoutType)
	weekType := weekType(resolvableDay, dayType)
	planType := planType(resolvableWeek, weekType)
	recordType := recordType()
	profileType := profileType(dbClient, recordType)
	workoutV2Type := workoutV2Type(dbClient, profileType)

	var queryType = graphql.NewObject(
		graphql.ObjectConfig{
			Name: "Query",
			Fields: graphql.Fields{
				"intensityZones": intensityZonesField(resolvableIntensityZones),
				"workouts":       workoutsField(resolvableWorkout, workoutType),
				"workout":        workoutField(resolvableWorkout, workoutType),
				"plans":          plansField(resolvablePlan, planType),
				"plan":           planField(resolvablePlan, planType),
				"profiles":       profilesField(dbClient, profileType),
				"profile":        profileField(dbClient, profileType),
				"me":             meField(profileType),
				"workoutV2s":     workoutV2sField(dbClient, workoutV2Type),
				"workoutV2":      workoutV2Field(dbClient, workoutV2Type),
			},
		})

	return graphql.NewSchema(
		graphql.SchemaConfig{
			Query: queryType,
		},
	)
}
