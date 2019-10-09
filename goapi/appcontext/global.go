package appcontext

import (
	"time"

	"github.com/sirupsen/logrus"
)

var (
	AppName      string
	AppPodName   string
	AppStartTime time.Time

	LogFactory LogFactoryFunc = func(fields logrus.Fields) *logrus.Entry {
		return NewNilLogger()
	}
)
