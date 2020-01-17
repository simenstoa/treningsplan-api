package mw

import (
	"goapi/appcontext"
	"goapi/database"
	"goapi/jwktokenvalidator"
	"goapi/logger"
	"goapi/server/problems"
	"goapi/server/responsewriter"
	"net/http"

	"github.com/gorilla/mux"
)

func Authentication(validator jwktokenvalidator.JwtTokenValidator, dbClient database.Client) mux.MiddlewareFunc {
	return func(handler http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ctx := r.Context()

			if r.Method == http.MethodOptions {
				handler.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			tokenStr := r.Header.Get("Authorization")
			if tokenStr == "" {
				ctx = appcontext.WithUserAuthenticated(ctx, false)
				log := logger.FromContext(ctx)
				log.Info("User not logged in")

				handler.ServeHTTP(w, r.WithContext(ctx))
			} else {
				token, err := validator.ParseAndValidateToken(ctx, tokenStr)
				if err != nil {
					abort := responsewriter.AbortHandler(w)
					log := logger.FromContext(ctx)
					log.WithError(err).Warn("invalid auth token")
					abort(ctx, problems.ErrInvalidAuthorizationToken)
					return
				}
				ctx = appcontext.WithAuth0Id(ctx, token.Auth0Id)

				profile, err := dbClient.GetProfileByAuth0Id(ctx, token.Auth0Id)
				if err != nil {
					abort := responsewriter.AbortHandler(w)
					log := logger.FromContext(ctx)
					log.WithError(err).Warn("Could not fetch profile for auth0Id")
					abort(ctx, problems.ErrInvalidAuthorizationToken)
					return
				}
				ctx = appcontext.WithUserAuthenticated(ctx, true)
				ctx = appcontext.WithProfile(ctx, profile)

				log := logger.FromContext(ctx)
				log.Info("User authenticated")

				handler.ServeHTTP(w, r.WithContext(ctx))
			}
		})
	}
}
