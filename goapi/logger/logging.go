package logger

import (
	"github.com/sirupsen/logrus"
	"strconv"
	"time"
)

func LogDuration(duration time.Duration) logrus.Fields {
	return logrus.Fields{
		durationKey: strconv.FormatInt(duration.Nanoseconds(), 10),
	}
}

func LogProblem(problemType string, problemStatusCode int) logrus.Fields {
	return logrus.Fields{
		problemTypeKey: problemType,
		statusCode:     problemStatusCode,
	}
}
