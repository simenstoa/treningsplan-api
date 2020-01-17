package appcontext

import (
	"context"
	"errors"
	"github.com/gofrs/uuid"
	"goapi/models"
	"time"
)

type ContextKey int

const (
	LoggerKey ContextKey = iota

	CorrelationIdKey
	PathKey
	requestStartKey
	OperationKey
	UserAuthenticatedKey
	Auth0IdKey
	ProfileKey
)

func WithProfile(ctx context.Context, profile models.Profile) context.Context {
	return context.WithValue(ctx, ProfileKey, profile)
}

func Profile(ctx context.Context) (models.Profile, error) {
	if profile, ok := ctx.Value(ProfileKey).(models.Profile); ok {
		return profile, nil
	}
	return models.Profile{}, notFoundOnContextError("Profile")
}

func WithUserAuthenticated(ctx context.Context, authenticated bool) context.Context {
	return context.WithValue(ctx, UserAuthenticatedKey, authenticated)
}

func UserAuthenticated(ctx context.Context) (bool, error) {
	return getBoolContextValue(ctx, UserAuthenticatedKey, "UserAuthenticated")
}

func WithAuth0Id(ctx context.Context, auth0Id string) context.Context {
	return context.WithValue(ctx, Auth0IdKey, auth0Id)
}

func Auth0Id(ctx context.Context) (string, error) {
	return getContextValue(ctx, Auth0IdKey, "Auth0Id")
}

func WithCorrelationId(ctx context.Context, correlationId string) context.Context {
	return context.WithValue(ctx, CorrelationIdKey, correlationId)
}

func CorrelationId(ctx context.Context) (string, error) {
	return getContextValue(ctx, CorrelationIdKey, "CorrelationId")
}

func WithPath(ctx context.Context, path string) context.Context {
	return context.WithValue(ctx, PathKey, path)
}

func WithRequestStart(ctx context.Context, time time.Time) context.Context {
	return context.WithValue(ctx, requestStartKey, time)
}

func RequestStart(ctx context.Context) time.Time {
	if val, ok := ctx.Value(requestStartKey).(time.Time); ok {
		return val
	}
	return time.Unix(0, 0)
}

func WithOperation(ctx context.Context, op operation) context.Context {
	return context.WithValue(ctx, OperationKey, string(op))
}

func GenerateCorrelationId() string {
	return uuid.Must(uuid.NewV4()).String()
}

func getContextValue(ctx context.Context, key ContextKey, keyName string) (string, error) {
	if val, ok := ctx.Value(key).(string); ok {
		return val, nil
	}
	return "", notFoundOnContextError(keyName)
}

func getBoolContextValue(ctx context.Context, key ContextKey, keyName string) (bool, error) {
	if val, ok := ctx.Value(key).(bool); ok {
		return val, nil
	}
	return false, notFoundOnContextError(keyName)
}

func notFoundOnContextError(keyName string) error {
	return errors.New(keyName + " not found on context")
}