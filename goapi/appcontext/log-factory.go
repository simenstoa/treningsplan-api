package appcontext

import (
	"goapi/config"
	"io"
	"io/ioutil"
	"os"
	"time"

	"github.com/pkg/errors"
	"github.com/sirupsen/logrus"
	"gopkg.in/natefinch/lumberjack.v2"
)

type LogFactoryFunc func(fields logrus.Fields) *logrus.Entry

func NewLogFactory(cfg *config.Config, baseFields logrus.Fields) LogFactoryFunc {
	log := newLogger(baseFields, cfg)

	return func(fields logrus.Fields) *logrus.Entry {
		if fields == nil {
			fields = logrus.Fields{}
		}

		// This will use the "base logger" from the closure and further contextualize it.
		return log.WithFields(fields)
	}
}

func newLogger(fields logrus.Fields, cfg *config.Config) *logrus.Entry {
	// Use Entry instead of FieldLogger in order to have access to the inner logger
	var log *logrus.Entry

	// Create a normal instance of logrus.Entry
	log = logrus.NewEntry(logrus.New())

	// Add common fields to logrus entries
	if fields != nil {
		log = log.WithFields(fields)
	}

	// If enabled, log everything as JSON
	if cfg.LogJson {
		log.Logger.Formatter = &logrus.JSONFormatter{
			TimestampFormat: time.RFC3339Nano,
		}
	}

	// Attempt to parse the level - defaults to debug if parsing fails
	lvl, err := logrus.ParseLevel(cfg.LogLevel)
	if err != nil {
		err = errors.WithStack(err)
		log.WithError(err).Warning("Invalid log level. Ensure the env. var. LOG_LEVEL is set correctly. Defaulting to debug.")
		lvl = logrus.DebugLevel
	}

	log.Logger.SetLevel(lvl)

	// If a log file is specified, use the multi-writer to write to stderr and lumberjack (log-rotator)
	if len(cfg.LogFile) > 0 {
		log.Logger.SetOutput(io.MultiWriter(os.Stderr,
			&lumberjack.Logger{
				Filename:   cfg.LogFile,
				MaxSize:    cfg.LogMaxSize,
				MaxBackups: cfg.LogMaxBackups,
				MaxAge:     cfg.LogMaxAge,
				Compress:   true,
			}))
	}

	return log
}

func NewNilLogger() *logrus.Entry {
	log := logrus.Logger{
		Level:     logrus.ErrorLevel,
		Out:       ioutil.Discard,
		Formatter: &logrus.TextFormatter{},
	}
	return logrus.NewEntry(&log)
}
