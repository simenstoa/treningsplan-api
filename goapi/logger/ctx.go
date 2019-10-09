package logger

import (
	"context"
	"goapi/appcontext"

	"github.com/sirupsen/logrus"
)

var logFieldByCtxKey = map[appcontext.ContextKey]string{
	// Default context value fields, present in all logs
	appcontext.CorrelationIdKey: "correlationId",
	appcontext.PathKey:          "path",

	// Optional context value fields, only present in logs when explicitly added
	appcontext.OperationKey: "operation",
}

func ContextWithLogger(ctx context.Context, logger *logrus.Entry) context.Context {
	return context.WithValue(ctx, appcontext.LoggerKey, logger)
}

// Returns a new logger with context parameters set as fields
func FromContext(ctx context.Context) *logrus.Entry {
	if ctx == nil {
		return appcontext.NewNilLogger()
	}

	if logger, ok := ctx.Value(appcontext.LoggerKey).(*logrus.Entry); ok {
		// Enrich the logger with the values found in the context
		fields := logrus.Fields{}
		for ctxKey, logField := range logFieldByCtxKey {
			if val, ok := ctx.Value(ctxKey).(string); ok {
				if val != "" {
					fields[logField] = val
				}
			}
		}

		return logger.WithFields(fields)
	}

	return appcontext.NewNilLogger()
}
