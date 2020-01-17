package jwktokenvalidator

import (
	"context"
	"errors"
	"github.com/dgrijalva/jwt-go"
	"goapi/logger"
)

type JwtTokenValidator interface {
	ParseAndValidateToken(ctx context.Context, tokenString string) (*Token, error)
}

func NewJwtTokenValidator(pkStore PublicKeyStore) JwtTokenValidator {
	return &jwtTokenValidator{
		pkStore: pkStore,
	}
}

type jwtTokenValidator struct {
	pkStore PublicKeyStore
}

type CustomClaims struct {
	jwt.StandardClaims
	UserId string `json:"user_id,omitempty"`
}

type Token struct {
	Token   *jwt.Token
	Auth0Id string
}

func (v *jwtTokenValidator) ParseAndValidateToken(ctx context.Context, tokenString string) (*Token, error) {
	p := &jwt.Parser{}
	claims := jwt.StandardClaims{}
	log := logger.FromContext(ctx)

	t, err := p.ParseWithClaims(removeBearerPrefix(tokenString), &claims, newPublicKeyRetriever(ctx, v.pkStore))
	if err != nil {
		log.
			WithError(err).
			Warn("Could not validate access token")
		return nil, err
	}

	if t.Valid {
		userId, err := extractAuth0Id(t)
		if err != nil {
			log.
				WithError(err).
				Warn("Could not get auth0_id from access token")
			return nil, err
		}

		return &Token{
			Token:   t,
			Auth0Id: userId,
		}, nil
	} else {
		log.
			WithError(err).
			Warn("Could not validate access token")
		return nil, err
	}
}

func extractAuth0Id(t *jwt.Token) (string, error) {
	claims, ok := t.Claims.(*jwt.StandardClaims)
	if ok {
		return claims.Subject, nil
	}

	return "", errors.New("auth0_id not found in claims")
}
