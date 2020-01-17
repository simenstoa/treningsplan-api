package jwktokenvalidator

import (
	"context"
	"crypto/rsa"
	"encoding/json"
	"goapi/logger"
	"net/http"
	"time"

	"github.com/lestrrat-go/jwx/jwa"
	"github.com/lestrrat-go/jwx/jwk"
	"github.com/pkg/errors"
)

const (
	openIdConfigurationUrl = "https://treningsplan.eu.auth0.com/.well-known/openid-configuration"
)

type PublicKeys map[string]*rsa.PublicKey

type PublicKeyStore interface {
	ByKeyID(ctx context.Context, keyID string) (*rsa.PublicKey, error)
}

type publicKeyStore struct {
	jwkFetcher JwkFetcher
}

type JwkFetcher func() (*jwk.Set, error)

func JwkFetcherForURL(jwkUrl string) JwkFetcher {
	return func() (*jwk.Set, error) {
		return jwk.Fetch(jwkUrl)
	}
}

func NewPublicKeyStore(ctx context.Context) (PublicKeyStore, error) {
	log := logger.FromContext(ctx)

	type openIdConfig struct {
		JwksUri string `json:"jwks_uri"`
	}

	client := &http.Client{Timeout: 10 * time.Second}
	req, err := http.NewRequest("GET", openIdConfigurationUrl, nil)
	if err != nil {
		return nil, err
	}

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer func() {
		err := resp.Body.Close()
		if err != nil {
			log.WithError(err).Warn("Could not close jwk store response.")
		}
	}()

	var result openIdConfig
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return nil, err
	}

	return publicKeyStore{jwkFetcher: JwkFetcherForURL(result.JwksUri)}, nil
}

func (pks publicKeyStore) ByKeyID(ctx context.Context, keyID string) (*rsa.PublicKey, error) {
	log := logger.FromContext(ctx)

	keys, err := pks.fetchKeys()
	if err != nil {
		log.WithError(err).Error("Failed to fetch keys")
		return &rsa.PublicKey{}, err
	}

	pk, ok := keys[keyID]
	if !ok {
		err := errors.New("Public key not found")
		log.WithError(err).Error(err)
		return nil, err
	}

	return pk, nil
}

func (pks publicKeyStore) fetchKeys() (PublicKeys, error) {
	set, err := pks.jwkFetcher()
	if err != nil {
		return PublicKeys{}, errors.Wrap(err, "Failed to retrieve JWK public key")
	}

	keys := set.Keys
	matKeys := make(map[string]*rsa.PublicKey)

	for _, k := range keys {
		if k.KeyType() == jwa.RSA {
			mk, err := k.Materialize()
			if err != nil {
				return PublicKeys{}, errors.New("Failed to create public key")
			}
			pk, ok := mk.(*rsa.PublicKey)
			if !ok {
				return PublicKeys{}, errors.New("Failed to create public key, wrong type")
			}
			matKeys[k.KeyID()] = pk
		}
	}

	return matKeys, nil
}
