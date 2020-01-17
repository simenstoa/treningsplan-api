package jwktokenvalidator

import (
	"context"
	"crypto/rsa"
	"github.com/dgrijalva/jwt-go"
	"github.com/pkg/errors"
	"strings"
)

func removeBearerPrefix(token string) string {
	// The "Bearer" string is not a part of the JWT-token, and is removed.
	// We do not currently enforce it, but that could be validated here.

	str := token
	str = strings.TrimPrefix(str, "Bearer")
	str = strings.TrimPrefix(str, "bearer")
	return strings.TrimSpace(str)
}

func newPublicKeyRetriever(ctx context.Context, pkStore PublicKeyStore) jwt.Keyfunc {
	return func(t *jwt.Token) (interface{}, error) {
		kid, ok := t.Header["kid"].(string)
		if !ok {
			return &rsa.PublicKey{}, errors.New("KID is not a string: " + kid)
		}

		pk, err := pkStore.ByKeyID(ctx, kid)
		if err != nil {
			return &rsa.PublicKey{}, errors.Wrapf(err, "Failed to find key with ID: [%s]", kid)
		}

		return pk, nil
	}
}
