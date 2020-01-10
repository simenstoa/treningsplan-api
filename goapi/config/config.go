package config

import (
	"github.com/kelseyhightower/envconfig"
	"log"
)

type Config struct {
	AirtableSecret string `split_words:"true"`

	PostgresHost     string `split_words:"true" default:"localhost"`
	PostgresPort     int    `split_words:"true" default:"5432"`
	PostgresUser     string `split_words:"true" default:""`
	PostgresPassword string `split_words:"true" default:""`
	PostgresName     string `split_words:"true" default:"strides"`

	LogJson       bool   `split_words:"true" default:"true"`
	LogLevel      string `split_words:"true" default:"debug"`
	LogFile       string `split_words:"true" default:""`
	LogMaxSize    int    `split_words:"true" default:"500"`
	LogMaxBackups int    `split_words:"true" default:"30"`
	LogMaxAge     int    `split_words:"true" default:"30"`
}

func FromEnv() Config {
	cfg := Config{}
	if err := envconfig.Process("", &cfg); err != nil {
		log.Fatal("Unable to process config")
	}

	return cfg
}
