package config

import (
	"github.com/kelseyhightower/envconfig"
	"log"
)

type Config struct {
	AirtableSecret string `split_words:"true"`
}

func FromEnv() Config {
	cfg := Config{}
	if err := envconfig.Process("", &cfg); err != nil {
		log.Fatal("Unable to process config")
	}

	return cfg
}