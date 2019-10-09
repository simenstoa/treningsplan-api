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
